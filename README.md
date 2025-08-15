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

File.json should be an array of project sets like so:

```
[
    {
        "id": 0,
        "projects": [
            {
                "name": "Set 0:0",
                "city_type": "low",
                "start_date": "10/1/24",
                "end_date": "10/4/24"
            }
        ]
    },
    {
        "id": 1,
        "projects": [
            {
                "name": "Set 1:0",
                "city_type": "low",
                "start_date": "10/1/24",
                "end_date": "10/1/24"
            },
            {
                "name": "Set 1:1",
                "city_type": "high",
                "start_date": "10/2/24",
                "end_date": "10/6/24"
            },
            {
                "name": "Set 1:2",
                "city_type": "low",
                "start_date": "10/6/24",
                "end_date": "10/9/24"
            }
        ]
    }
]
```

id: is an integer identifier of the project set

name: is any name you would like for the particular project

You can find an example JSON file with the sample data in SimpleThreadCalculator/Sources/SimpleThreadCalculator/Resources/examples.json

## Running Tests

To run the test suite run the following from the root package directory

```
swift test
```


