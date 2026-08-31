# Local Java and Maven toolchain

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- macOS: 26.4.1, build 25E253.
- Darwin: 25.4.0, `RELEASE_ARM64_T6000`.
- Architecture: `arm64` (`aarch64` in Maven output).
- Hostname and unrelated machine details are intentionally omitted.

DrivenByMoss 26.4.1 requires Java 21 and Maven 3.8.1 or newer.

## Initial inspection

Commands run before the build included:

```text
sw_vers
uname -a
uname -m
/usr/libexec/java_home -V
java -version
javac -version
which java
which javac
which mvn
printenv JAVA_HOME
```

Initial results:

- `JAVA_HOME` was unset.
- `/usr/bin/java` and `/usr/bin/javac` selected registered Temurin 25.0.1.
- `/usr/libexec/java_home -V` listed Temurin 25.0.1 arm64 and Temurin 16.0.2 x86_64; it did not list the Homebrew Java 21 installation.
- No `mvn` executable was initially available on `PATH`, and the source repository had no Maven wrapper.
- An existing Homebrew Java 21 installation was found at `/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`.

No source or `pom.xml` change was used to work around the missing Maven executable.

## Authorized Maven installation

The maintainer explicitly authorized installing Maven. The command was:

```text
brew install maven
```

Homebrew 6.0.20 installed Maven 3.9.16. Its dependency transaction also installed unversioned OpenJDK 26.0.2.1 and upgraded the `webp`, `libtiff`, and `little-cms2` formulae. The build did not use Java 26.

Installed formula readback after the transaction:

```text
maven 3.9.16
openjdk 26.0.2.1
openjdk@21 21.0.11
```

The post-install default `mvn --version` selected Homebrew Java 26.0.2.1, so relying on the default environment would not meet the Java 21 authority.

## Exact build environment

The build explicitly selected the already-present Java 21 JDK:

```text
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
PATH=$JAVA_HOME/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

Version readback inside that environment:

```text
openjdk version "21.0.11" 2026-04-21
OpenJDK Runtime Environment Homebrew (build 21.0.11)
OpenJDK 64-Bit Server VM Homebrew (build 21.0.11, mixed mode, sharing)
javac 21.0.11
Apache Maven 3.9.16 (2bdd9fddda4b155ebf8000e807eb73fd829a51d5)
Maven home: /opt/homebrew/Cellar/maven/3.9.16/libexec
Java version: 21.0.11, vendor: Homebrew
OS name: "mac os x", version: "26.4.1", arch: "aarch64"
```

Executable resolution inside the build environment:

```text
$JAVA_HOME/bin/java
$JAVA_HOME/bin/javac
/opt/homebrew/bin/mvn
```

## Tools and commands used

- `sw_vers`, `uname`
- `/usr/libexec/java_home -V`
- `java -version`, `javac -version`, `mvn --version`
- `which`, `printenv`
- `brew install maven`, `brew list --versions`, `brew --version`
- `env` with an explicit Java 21 `JAVA_HOME` and bounded `PATH`

## What this evidence proves

- The accepted Mac has a working Java 21 JDK.
- Maven 3.9.16 satisfies the minimum Maven version.
- The build command actually ran Maven under Java 21 rather than the host's Java 25 or Maven's post-install Java 26 default.
- The one required package-manager action was explicit and maintainer-authorized.

## What this evidence does not prove

- It does not register Homebrew Java 21 with `/usr/libexec/java_home`.
- It does not change the user's global `JAVA_HOME` or default Java selection.
- It does not claim the Maven installation was side-effect-free; the dependency transaction is stated above.
- It does not prove the source build succeeded; that result is retained in `build-result.md`.
