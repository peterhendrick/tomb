

TOMB!
=======

tomb is an extension for the pass package in homebrew for mac.

**Author:** Peter Hendrick

## Requirements and Downloading

To use tomb, you need:

* The Bourne Again Shell - bash: to execute the script. This should come pre-installed in mac and linux.

* Xcode (for mac users) - mac developer tools. You'll need Xcode to use git source control.

* git - the stupid content tracker: You'll need git to download and update your tomb file.

* GnuPG - Gnu Privacy Guard (required): to encrypt/decrypt files while using tomb'.

* tar - A native unix file compressor: creates and manipulates streaming archive files.  This implementation can extract from tar, pax, cpio, zip, jar, ar, and ISO 9660
     cdrom images and can create tar, pax, cpio, ar, and shar archives

* pass - a homebrew password manager package.


## Getting Started

First download tomb. Open up your terminal and type:
```bash
git clone https://github.com/peterhendrick/tomb.git ~/tomb/ && cd ~/tomb
```

It is recommended that you verify your download before executing any files downloaded from the internet. You can see instructions for verifying your download near the bottom of this readme.

Once you've verified the download using the SHASUM and SHASUM.sig files, give permission to the current user to execute the tomb.sh file.

```bash
chmod u+x ~/tomb/tomb.sh
```
* chmod - this program is native to unix and modifies file permissions. See more by typing "man chmod".
* u+x - this argument gives the present user permission to execute the file specified in the next argument (./tomb.sh).

You'll want to create a symlink in your path to execute tomb.

```bash
mkdir ~/bin/ && ln -s ~/tomb/tomb.sh ~/bin/tomb
```

Then you'll want to add ~/bin to your PATH

```bash
echo "export PATH=${PATH}:~/bin/" >> ~/.bash_profile && source ~/.bash_profile
```

If done correctly, you should see this when typing 'which tomb':

```bash
$ which tomb
/Users/<your user>/bin/tomb
```

Before starting with tomb, you're going to need to have pass installed. You can get that through homebrew, which can be downloaded and installed here: https://brew.sh/

```bash
brew install pass
```

Then you can read pass's documentation here: https://www.passwordstore.org/

Once you have pass installed type:

```bash
pass init
```

And go through the setup. (gpg required)

It is recommended that you use pass to initialize a git repo for your encrypted passwords so that you can have a record of past changes (stored encrypted):
```bash
pass git init
```

pass will automatically add and commit changes to your ~/.password-store/ directory, however, password names are stored in plaintext. Tomb takes care of this information leak by first creating a gzipped tape archive (.tar.gz) file of the .password-store directory. It then uses gpg to encypt the .tar.gz file using your default gpg private key. Tomb will then remove the ~/.password-store directory so that only an enctypted .tar.gz.gpg file remains within the ~/.tomb/ directory. You can then easily decrypt, extract and open the tomb at any time and your original ~/.password-store directory will be restored.


You'll need to initialize tomb. Tomb expects git to be initialized in the ~/.tomb/ directory, so type:

```bash
tomb init
```

Tomb also expects your git repo to have a remote tied to it. So create a remote repo that you have access to, you can use github. Your file will be encrypted, so as long as you protect your gpg private key, and back it up securely, no one but you can decrypt the files on github. Backing up your tomb to a cloud source will ensure that even if you lose your electronics in a fire, you will still have your password store (so long as you safely backup your gpg secret key).

Once your remote repo is setup type:
```bash
git -C ~/.tomb/ remote add origin <SSH to remote>
```

You'll also want to configure your tomb's git repo to set yourself as the author of your commits, and to sign your commits, type the following commands:
```bash
git -C ~/.tomb/ config user.name "Yourname"
git -C ~/.tomb/ config user.email "youremail"
git -C ~/.tomb/ config user.signingkey "your gpg key"
git -C ~/.tomb/ config commit.gpgsign true
```

To create or update your tomb, after you have initialized the ~/.tomb/ directory and git initialized your ~/.tomb dir, simply type:
```bash
tomb close
```

This will archive and encrypt your password store and remove the ~/.password-store directory, ensuring that even the password names are not accessible without first decrypting. Tomb will hash your compressed password store and compare it to the latest hash taken, so that if there are no changes to the password store, then it will abort updating your tomb's git repo. Your password store's original git repo will be preserved during this compression and encryption. It is not recommended that you publish your plaintext password store on a git remote, since password names can expose which sites you have passwords to, even if the password itself is not accessible.

To open the tomb back up, type:

```bash
tomb open
```

This will decrypt, extract and copy your tomb to the ~/.password-store directory. pass will be open and operate just as it was if it was never put in a tomb.

To see if the password store tomb is open or closed, type:
```bash
tomb status
```

This will tell you if the ~/.password-store/ directory exists already. If it does exist, the tomb is considered open. If it doesn't exist the tomb is assumed to be closed.

Used properly, tomb will allow you to have personally controlled, secure cloud storage of your passwords. As long as you have a safe backup of your gpg secret key, you, and only you, will always be able to access your passwords.



## Verifying Your Download

You are going to want to verify the file you download is legitimate. To do this, I've included a SHASUM file containing a sha256 hash of the tomb.sh script.

When using tools for things like hiding files, you want to have absolute confidence in the legitimacy of your tools. Verifying your downloads is a good habit
to get into. Comparing sha256 hashes is good, and will help verify that downloads happen without corruption, but using GnuPG is the ultimate confidence in your tools. If the author uses gpg to sign their tools, you can be as absolutely certain as possible that your tools are legitimate.

After downloading:

```bash
shasum -a 256 ~/tomb/tomb.sh && cat ~/tomb/SHASUM
```
You should see output similar to this:
```bash
442298e67603b80d4db2e42ba98bb8bd9feb3c652840704e98163949cbbf6f01  tomb.sh
442298e67603b80d4db2e42ba98bb8bd9feb3c652840704e98163949cbbf6f01  tomb.sh
```
* shasum - a program to calculate a hash of a file.
* -a - to specify the algorithm (256) to calculate the hash of the input file (tomb.sh).
* && - to do two commands at once if the first command succeeds.
* cat - a program to concatenate output from a given file (SHASUM).

The hexadecimal string on the first line of the output represents a unique identity of the downloaded tomb.sh file.
The second line is text of the sha256 that I calculated on my personal machine. If they match, you likely have an identical file to the one I wrote.

If both lines of the output DO NOT match EXACTLY. Then STOP and reflect on what you've done so far. DELETE your tomb folder and re-download. It's possible that something went wrong while downloading.

If both output lines DO match EXACTLY, then that's good, but it is still not enough to be absolutely certain that your download is legitimate. A good hacker could give you a malicious tomb.sh file and update the SHASUM file to match their malicious file.

To defend against this type of attack, I have used GnuPG to sign the SHASUM file.

You are going to want to verify the SHASUM.sig file is a valid gpg signature for the SHASUM file. In order to do this, you will need to import my gpg public key. Type into bash:

```bash
gpg --keyserver hkp://keys.gnupg.net --recv-key EC3ED53D
```
* gpg - an open source encryption program.
* --keyserver - this argument specifies the remote keyserver in which to receive my public key.
* --recv-key - import the key that matches the next argument.


You now have my public key imported on your machine. You can now verify the SHASUM.sig file. In bash type:

```bash
gpg --verify ~/tomb/SHASUM.sig ~/tomb/SHASUM
```
* --verify this argument verifies my gpg signature file against the SHASUM file specified in the last argument.

You should see the following as part of the output:

```bash
gpg: Good signature from "Peter Hendrick <myemail>"
```

If you see the "Good signature", you can be as certain as possible that the SHASUM file is the file I wrote. Verifying the gpg signature along with verifying that the "shasum -a 256 tomb.sh" hash matches the text in the SHASUM file means you can have near absolute certainty that the tomb.sh file downloaded on your computer is Byte for Byte identical to the tomb.sh file I wrote. GPG is military grade encryption, so there are no known hacks to break the encryption. The only way for someone to fake my signature is for them to digitally capture my gpg secret key and also know my passphrase for the secret key.

If you have my gpg public key, and you would like to use one command for the verification, you can type:

```bash
cat ~/tomb/SHASUM && shasum -a 256 ~/tomb/tomb.sh && gpg --verify ~/tomb/SHASUM.sig ~/tomb/SHASUM
```

You should see output similar to this:

```bash
31ba208c3034761b19a71656f8df57a4d038462aaaf6d633daf8153fe1c05ce1  tomb.sh
31ba208c3034761b19a71656f8df57a4d038462aaaf6d633daf8153fe1c05ce1  tomb.sh
gpg: Signature made Mon Nov 20 22:46:21 2017 UTC using RSA key ID EC3ED53D
gpg: Good signature from "Peter Hendrick <myemail>"
```


