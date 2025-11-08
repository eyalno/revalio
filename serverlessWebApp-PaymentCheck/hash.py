from passlib.hash import pbkdf2_sha256

new_hash = pbkdf2_sha256.hash("jackson")
print(new_hash)