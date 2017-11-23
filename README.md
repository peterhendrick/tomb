=======


TOMB!
=======

tomb is an extension for the pass package in homebrew for mac.

**Author:** Peter Hendrick

## Requirements and Downloading

To use steggin, you need:

* The Bourne Again Shell - bash: to execute the script. This should come pre-installed in mac and linux.

* Xcode (for mac users) - mac developer tools. You'll need Xcode to use git source control.

* git - the stupid content tracker: You'll need git to download and update your steggin file.

* GnuPG - Gnu Privacy Guard (optional): to verify your download and encrypt/decrypt files while steggin'.

* pass - a homebrew password manager package.

The rest of this README will assume your bash commands are executed within the tomb directory (folder).


## Verifying Your Download

You are going to want to verify the file you download is legitimate. To do this, I've included a SHASUM file containing a sha256 hash of the steggin.sh script.

When using tools for things like hiding files, you want to have absolute confidence in the legitimacy of your tools. Verifying your downloads is a good habit to get into. Comparing sha256 hashes is good, and will help verify that downloads happen without corruption, but using GnuPG is the ultimate confidence in your tools. If the author uses gpg to sign their tools, you can be as absolutely certain as possible that your tools are legitimate.

After downloading, while your present working directory (pwd) is tomb/, type into bash:

```bash
shasum -a 256 tomb.sh && cat SHASUM
```
You should see output similar to this:
```bash
442298e67603b80d4db2e42ba98bb8bd9feb3c652840704e98163949cbbf6f01  tomb.sh
442298e67603b80d4db2e42ba98bb8bd9feb3c652840704e98163949cbbf6f01  tomb.sh
```
* shasum - a program to calculate a hash of a file.
* -a - to specify the algorithm (256) to calculate the hash of the input file (steggin.sh).
* && - to do two commands at once if the first command succeeds.
* cat - a program to concatenate output from a given file (SHASUM).

The hexadecimal string on the first line of the output represents a unique identity of the downloaded steggin.sh file.
The second line is text of the sha256 that I calculated on my personal machine. If they match, you likely have an identical file to the one I wrote.

If both lines of the output DO NOT match EXACTLY. Then STOP and reflect on what you've done so far. DELETE your steggin folder and re-download. It's possible that something went wrong while downloading.

If both output lines DO match EXACTLY, then that's good, but it is still not enough to be absolutely certain that your download is legitimate. A good hacker could give you a malicious steggin.sh file and update the SHASUM file to match their malicious file.

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
gpg --verify SHASUM.sig SHASUM
```
* --verify this argument verifies my gpg signature file against the SHASUM file specified in the last argument.

You should see the following as part of the output:

```bash
gpg: Good signature from "Peter Hendrick <myemail>"
```

If you see the "Good signature", you can be as certain as possible that the SHASUM file is the file I wrote. Verifying the gpg signature along with verifying that the "shasum -a 256 steggin.sh" hash matches the text in the SHASUM file means you can have near absolute certainty that the steggin.sh file downloaded on your computer is Byte for Byte identical to the steggin.sh file I wrote. GPG is military grade encryption, so there are no known hacks to break the encryption. The only way for someone to fake my signature is for them to digitally capture my gpg secret key and also know my passphrase for the secret key.

If you have my gpg public key, and you would like to use one command for the verification, you can type:

```bash
cat SHASUM && shasum -a 256 tomb.sh && gpg --verify SHASUM.sig SHASUM
```

You should see output similar to this:

```bash
31ba208c3034761b19a71656f8df57a4d038462aaaf6d633daf8153fe1c05ce1  steggin.sh
31ba208c3034761b19a71656f8df57a4d038462aaaf6d633daf8153fe1c05ce1  steggin.sh
gpg: Signature made Mon Aug 29 22:46:21 2016 UTC using RSA key ID EC3ED53D
gpg: Good signature from "Peter Hendrick <myemail>"
```


## Getting Started

Now that you've verified the authenticity of the steggin file, you need to give yourself permission to execute the steggin.sh file. Type the command:

```bash
chmod u+x ./tomb.sh
```
* chmod - this program is native to unix and modifies file permissions. See more by typing "man chmod".
* u+x - this argument gives the present user permission to execute the file specified in the next argument (./steggin.sh).

You'll want to create a symlink in your path to execute tomb.

```bash
mkdir ~/bin/ && ln -s ~/tomb/tomb.sh ~/bin/tomb
```

Then you'll want to add ~/bin to your PATH

```bash
echo "export PATH=${PATH}:~/bin/
```

If done correctly, you should see this when typing 'which tomb':

```bash
$ which tomb
/Users/<your user>/bin/tomb
```

