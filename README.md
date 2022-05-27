#  outdoor-sy
🛶 A simple CLI to read and parse a `.txt` file representing Outdoor.sy customers and output those customers in JSON.

## Setup
Setup should _hopefully_ be simple and easy.

### Clone this repo
```
# Via HTTPS (can do it via SSH or GH CLI if that's your preference):
$ git clone https://github.com/jjwyse/outdoor-sy.git

$ cd outdoor-sy
```

### Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) 2.7.2.
I used [rvm](http://rvm.io/). I'm actually not the biggest fan, but it's the ruby version manager I have on this computer so it was fastest for me personally.

### Install dependency (literally 1)
```
$ bundle install
``` 

## Running
### Examples
```
# Read pipes.txt file and sort by full name of customers ascending
$ app/index.rb pipes.txt '|' full_name

# Read pipes.txt file and sort by vehicle type of customers ascending
$ app/index.rb pipes.txt '|' vehicle_type

# Read commas.txt file and sort by full name of customers ascending
$ app/index.rb commas.txt ',' full_name

# Read commas.txt file and sort by vehicle type of customers ascending
$ app/index.rb commas.txt ',' vehicle_type
```

## Overview
This was fun! I time boxed things to ~two hours because frankly it was all I had today and wanted to get something back 
sooner than later. While I would have loved to do quite a few more things, I opted to keep things simple, prioritize 
something over perfection (this is a common tradeoff/tension I have found when working in small companies 😊),
and try to thoroughly document what was in my head and what I would do given more time, more requirements, more product-related
use cases, etc (See "Next steps" below). When building this, I tried to prioritize simplicity, testability, and velocity over 
pretty much everything else, given there were limited long-term requirements about where we might go with this and I had a two hour time window. This means I 
_almost_ used no dependencies, but actually ended up adding [`rspec`](https://rspec.info/) because I am very familiar with
this testing framework, and it made it easier and faster for me to write unit tests. I opted not to use any type of
CLI-related gem, although that would definitely provide a cleaner interface for users. The top drivers for me personally
when writing code are ~ does it work, is it tested, and is it obvious. The first two are kind of duh, but re "obvious", 
I believe the majority of time as engineers is spent reading and trying to understand code, so the faster and easier I 
can make that for others is a high priority.

## Next steps
As I mentioned above, there were many things going through my head while building out this app. Below, I try to shed
a little bit of light onto them:
- Customer PORO? Vehicle PORO? - I opted to just make a simple Hash to represent an Outdoor.sy customer. This has its
limitations, and the app _could_ benefit from being more OO and having a Customer object and/or a Vehicle object. Right
now it appears there is a 1:1 relationship between a Customer and a Vehicle, but I suspect this could be a 1:many in 
reality. eg [I suspect Jimmy B has > 1 sailboat](https://www.buffettnews.com/resources/boatsplanes/), etc. Although,
depending on how Outdoor.sy's product works, maybe there's a separate customer object for each boat Jimmy has or something.
- Allow client to specify different data type format responses - this just returns a JSON representation of the customers 
in the terminal, however it would have been ~trivial to support different formats, should we find that useful to our users.
- Many many assumptions about input - the two files given were simple. Additionally, it was mentioned in the instructions
that _The data will be separated by a pipe or a comma and the data fields themselves don’t contain those separators_, 
which was a nice simplifier when it came to parsing. Regardless of these though, just splitting a String and assuming
each entry maps to specific attributes of a customer is fragile. Considered doing a regex here, but it seemed overkill 
for now, but we'd likely want more validations around this input to ensure we're not creating bad data which will lead
to implicit bugs downstream.
- Cleaning data - There were a few things I noticed here. First, we should consider parsing the vehicle length into common 
data type as currently, the vehicle length data can come in a few different formats (eg, 32', 28 feet, 40 ft). Standardizing 
on a specific data type here would be useful were other parts of our application going to rely on this data. Personally, 
I would have standardized on some numeric data type, an integer would probably be fine (pending units), and then a certain 
unit (eg inches, feet, meters). In my head, meters makes the most sense since Imperial units are silly, but I would want 
to learn more about the data and consult with others (Product, etc) on this. The same could apply
for our `vehicle_type` attribute, and really all attributes in general. We'd want to ensure we have consistent data types,
units, etc. across the board to ensure we don't have downstream problems. Bad data in, bad data out. 
- Relative paths, etc. is ugly and fragile - Throughout I'm doing things like `require_relative` and also assuming the
`index.rb` file is _only_ going to be executed from the root directly of this app. However, if you ran it from the `app`
directory for example, you're going to get "No such file or directory" errors. This is heinous and something I'd clean up.
- Handling scale - the current implementation assumes the files are small. There are _many_ things to consider when
it comes to scale here that are not demonstrated. Some things top of mind:
  - Could batch load each customer from the File using eg `#find_each` to reduce RAM usage if the File is large
  - Could parallelize the parsing (shard to workers, spin up threads, etc.)
  - If file is relatively static, we could persist the data to disk somehow (DB, etc.) as we parse. This was really top
 of mind for me, as if we're going to build anything on top of this data, this is likely what we're going to want to do
 in addition to "cleaning" up the data as is mentioned above.
  - In general, would love to hear more about where this product might go and how it might be used to help inform things
 around scale. No need to over-engineer here, if this is as big a dataset as we're going to get or something. Keep things
 pragmatic.
- Currently the app just sorts in ascending order based on the `sort_by` parameter. Could easily support ascending, 
descending, and more sort types in general, should that be something our users would find useful.
- Unnecessary to require a delimiter if just two files with well-known delimiter for each - given how simple the options are for the CLI right now, I could have
just mapped the `commas.txt` file to have a `,` delimiter, and same for the `pipes.txt` to help eliminate a potential user error.
- Error handling is naive. While the service itself does some very rudimentary validation of inputs, the CLI is not
especially user friendly should you experience any of these errors, eg
```
$ app/index.rb pipes.txt '|' bob
Traceback (most recent call last):
	1: from app/index.rb:28:in `<main>'
/Users/jjwyse/workspace/outdoor-sy/app/services/parse_customer_service.rb:32:in `execute': ParseCustomerService::InvalidSortByError (ParseCustomerService::InvalidSortByError)
```
- Lastly, I was originally just `pp customers.to_json` in the CLI `index.rb` as the output however the String has its 
double quotes escaped and it's just ugly, so I ended up writing it to an `output.json` file and then doing a `cat output.json` in the Ruby code.
I also personally added a `| jq` on to the end of that to see it beautified, and be able to manipulate the JSON easily in the terminal. 
This requires [jq](https://stedolan.github.io/jq/), which is just an option. But my point here is there has to be a better way
of doing this, and I was just timing out looking for a better solution.