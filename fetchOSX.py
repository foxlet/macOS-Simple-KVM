import os

print("Mojave : 1")
print("Catalina : 2")
print("Big Sur : 3")
print  ("Monterey : 4")
osxver = input("Enter Version: ")

if osxver == 1:
  os.system("python macrecovery.py -b Mac-7BA5B2DFE22DDD8C -m 00000000000KXPG00 download")
elif osxver == 2:
 os.system(" python macrecovery.py -b Mac-00BE6ED71E35EB86 -m 00000000000000000 download")
elif osxver == 3:
 os.system(" python macrecovery.py -b Mac-42FD25EABCABB274 -m 00000000000000000 download")
else:
 os.system(" python ./macrecovery.py -b Mac-E43C1C25D4880AD6 -m 00000000000000000 download")

 os.system("qemu-img convert BaseSystem.dmg -O raw BaseSystem.img")
