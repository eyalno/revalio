 #pip3 install passlib

from passlib.hash import pbkdf2_sha256

password = input("Enter password to hash: ")

hashed = pbkdf2_sha256.hash(password)

print("Hashed password:")
print(hashed)