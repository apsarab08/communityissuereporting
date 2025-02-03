from werkzeug.security import generate_password_hash

# Specify the password you want to hash
password = 'ad3'

# Generate the hashed password
hashed_password = generate_password_hash(password)

# Print the hashed password
print(f'Hashed Password: {hashed_password}')
