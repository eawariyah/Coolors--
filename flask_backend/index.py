import json
from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import hashlib
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

app = Flask(__name__)
CORS(app)

# Initializing and getting reference to Firestore database.
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)

# Get a reference to the Firestore database
db = firestore.client()

# create a reference to the 'users_data' collection in Firestore
users_ref = db.collection('users')

# Create a reference to the 'rgb_data' collection in Firestore
rgb_data_ref = db.collection('rgb_data')


# route to register a new user
@app.route('/users_data', methods=['POST'])
def register_user():
    user_data = json.loads(request.data)
    email = user_data.get('email')
    password = user_data.get('password')
    if not email or not password:
        return jsonify({'error': 'Email or password missing'})

    # Check if the email already exists
    user_query = users_ref.where('email', '==', email).get()
    if len(user_query) > 0:
        return jsonify({'error': 'Email already exists'})

    # Hash the password and store the user data in the database
    password_hash = hashlib.sha256(password.encode()).hexdigest()
    user_data['password'] = password_hash
    user_doc = users_ref.add(user_data)[1]
    return jsonify({'message': 'New user registered successfully', 'user_id': user_doc.id, 'user_data': user_data})


# route to get all users
@app.route('/users_data', methods=['GET'])
def get_all_users():
    users = []
    for doc in users_ref.stream():
        users.append(doc.to_dict())
    return jsonify(users)

# route to authenticate user


@app.route('/login', methods=['POST'])
def login():
    user_data = json.loads(request.data)
    email = user_data.get('email')
    password = user_data.get('password')
    if not email or not password:
        return jsonify({'error': 'Email or password missing'}), 401

    # Query the database for the user with the given email
    user_query = users_ref.where('email', '==', email).limit(1).get()
    if len(user_query) == 0:
        return jsonify({'error': 'Invalid email or password'}), 401

    # Get the user document
    user_doc = user_query[0]

    # Get the hashed password stored in the database
    password_hash = user_doc.get('password')

    # Hash the entered password and compare it with the stored password hash
    entered_password_hash = hashlib.sha256(password.encode()).hexdigest()
    if entered_password_hash != password_hash:
        return jsonify({'error': 'Invalid email or password'}), 401

    # Return the user id along with the message 'Login successful'
    return jsonify({'message': 'Login successful', 'user_id': user_doc.id})

# route to get the current user id


@app.route('/users_data/current_user_id', methods=['GET'])
def get_current_user_id():
    # Get the user id from the request header
    user_id = request.headers.get('user_id')
    if user_id:
        return jsonify({'user_id': user_id})
    else:
        return jsonify({'error': 'User not authenticated'})


# route to get the current user id from their email
@app.route('/users_data/current_user_id_from_email', methods=['GET'])
def get_current_user_id_from_email():
    email = request.args.get('email')
    if email:
        user_query = users_ref.where('email', '==', email).limit(1).get()
        if len(user_query) == 0:
            return jsonify({'error': 'User not found'})
        user_doc = user_query[0]

        user_doc = users_ref.document(user_doc.id).get()
        user_email = user_doc.get('email')
        user_password = user_doc.get('password')

        # get all the users in the database
        all_users = users_ref.get()
        recipients = []
        for user in all_users:
            # skip the current user
            if user.id == user_doc.id:
                continue
            recipients.append(user.get('email'))

        # create the email message
        subject = 'Update made! Checkout Now!'
        message = 'Hi,\n\nAn update has been made. Please check it out.\n\nThanks!'
        msg = MIMEMultipart()
        msg['From'] = user_email
        msg['To'] = ', '.join(recipients)
        msg['Subject'] = subject
        msg.attach(MIMEText(message, 'plain'))

        # send the email using SMTP
        try:
            smtp_server = 'smtp.gmail.com'
            smtp_port = 587
            smtp_username = 'eawariyah.ea@gmail.com'
            smtp_password = 'bqrftgsheaxvkrva'
            smtp_conn = smtplib.SMTP(smtp_server, smtp_port)
            smtp_conn.starttls()
            smtp_conn.login(smtp_username, smtp_password)
            smtp_conn.sendmail(user_email, recipients, msg.as_string())
            smtp_conn.quit()
            print(jsonify({'message': 'Email sent successfully'}))
        except Exception as e:
            print(
                jsonify({'error': 'Failed to send email: {}'.format(str(e))}))

        return jsonify({'user_id': user_doc.id})
    else:
        return jsonify({'error': 'Email not provided'})

# route to update user information


@app.route('/users_data/<user_id>', methods=['PUT'])
def update_user(user_id):
    user_doc = users_ref.document(user_id)
    if user_doc.get().exists:
        user_data = json.loads(request.data)
        user_doc.update(user_data)
        return jsonify({'message': 'User information updated successfully'})
    else:
        return jsonify({'error': 'User not found'})

# route to get user information


@app.route('/users_data/<user_id>', methods=['GET'])
def get_user(user_id):
    user_doc = users_ref.document(user_id)
    if user_doc.get().exists:
        return jsonify(user_doc.to_dict())
    else:
        return jsonify({'error': 'User not found'})


# Route to create a new batch of RGB data for a user
@app.route('/users_data/<user_id>/rgb_data', methods=['POST'])
def create_rgb_data(user_id):
    user_doc = users_ref.document(user_id)
    if not user_doc.get().exists:
        return jsonify({'error': 'User not found'})

    rgb_data = json.loads(request.data)
    if not rgb_data or len(rgb_data) != 5:
        return jsonify({'error': 'Invalid RGB data'})

    batch_data = []
    for rgb in rgb_data:
        r, g, b, text = rgb.get('r'), rgb.get(
            'g'), rgb.get('b'), rgb.get('text')
        if r is None or g is None or b is None or text is None:
            return jsonify({'error': 'Invalid RGB data'})

        batch_data.append({
            'r': r,
            'g': g,
            'b': b,
            'text': text
        })

    # Add the RGB data to the database
    rgb_data_doc = rgb_data_ref.add({
        'user_id': user_id,
        'batch_data': batch_data
    })[1]

    return jsonify({'message': 'New batch of RGB data added successfully', 'batch_id': rgb_data_doc.id})

# Route to get all batches of RGB data for a user


@app.route('/users_data/<user_id>/rgb_data', methods=['GET'])
def get_rgb_data(user_id):
    user_doc = users_ref.document(user_id)
    if not user_doc.get().exists:
        return jsonify({'error': 'User not found'})

    rgb_data_query = rgb_data_ref.where('user_id', '==', user_id).get()
    rgb_data = []
    for doc in rgb_data_query:
        rgb_data.append({
            'batch_id': doc.id,
            'batch_data': doc.get('batch_data')
        })

    return jsonify(rgb_data)

# Route to update a batch of RGB data for a user


@app.route('/users_data/<user_id>/rgb_data/<batch_id>', methods=['PUT'])
def update_rgb_data(user_id, batch_id):
    user_doc = users_ref.document(user_id)
    if not user_doc.get().exists:
        return jsonify({'error': 'User not found'})

    rgb_data_doc = rgb_data_ref.document(batch_id)
    if not rgb_data_doc.get().exists:
        return jsonify({'error': 'Batch not found'})

    rgb_data = json.loads(request.data)
    if not rgb_data or len(rgb_data) != 5:
        return jsonify({'error': 'Invalid RGB data'})

    batch_data = []
    for rgb in rgb_data:
        r, g, b, text = rgb.get('r'), rgb.get(
            'g'), rgb.get('b'), rgb.get('text')
        if r is None or g is None or b is None or text is None:
            return jsonify({'error': 'Invalid RGB data'})

        batch_data.append({
            'r': r,
            'g': g,
            'b': b,
            'text': text
        })

    # Update the RGB data in the database
    rgb_data_doc.update({
        'batch_data': batch_data
    })

    return jsonify({'message': 'Batch of RGB data updated successfully'})

# Route to get all batches of RGB data for all users


@app.route('/rgb_data', methods=['GET'])
def get_all_rgb_data():
    rgb_data_query = rgb_data_ref.get()
    rgb_data = []
    for doc in rgb_data_query:
        rgb_data.append({
            'user_id': doc.get('user_id'),
            'batch_id': doc.id,
            'batch_data': doc.get('batch_data')
        })

    return jsonify(rgb_data)


if __name__ == '__main__':
    app.run(debug=True)
