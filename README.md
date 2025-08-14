# SimpleThreadCalculator

This is my Github repo for the Simple Thread Tech Assessment. This project is implemented as a command line utility in Swift. This command line utility was made using a Mac and swift-tools-version: 6.1. Please see swift.org to find out how to install the latest swift toolchain for your platform of choice. 

My approach to the problem is described in Design_History/Design_History_File.md

## Installation

To install first clone the repo

```
git clone https://github.com/ahmedhumza94/SimpleThreadCalculator.git
```

Then enter the Package folder

```
cd SimpleThreadCalculator/SimpleThreadCalculator
```

To build for installation from the Terminal

```
swift build -c release
```

Then copy to /usr/local/bin

```
cd .build/release
sudo cp SimpleThreadCalculator /usr/local/bin
```

Then in a new terminal run as 

```
SimpleThreadCalculator /path/to/file.json --verbose
```

## Running Tests

To run the test suite run the following from the root package directory

```
swift test
```


