linkedin-contact-ranker-test
============================

Ranks your linked in contacts by importance with a secret sauce


## Step 1

#### Export your linkedin consumer secret and api key to the environment

Get one from here [https://www.linkedin.com/secure/developer](https://www.linkedin.com/secure/developer)


``` 
export LINKEDIN_API_KEY=YOUR_API_KEY
export LINKEDIN_API_SECRET=YOUR_SECRET

# the script will help you generate these if you dont have them already
export LINKEDIN_API_USER_ACCESS_KEY=YOUR_KEY
export LINKEDIN_API_USER_ACCESS_TOKEN=YOUR_TOKEN

```

## Step 2

#### Run the rake task. It will prompt you for the other actions you need to complete


```
bundle exec rake contact_ranker:generate_csvs

```

## Step 3

Checkout `most_valuable_contacts.csv` and `least_valuable_contacts.csv` in the directory once the task is complete.

## Step 4

###PROFIT!
