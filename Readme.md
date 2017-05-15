# Konviv API

#### Konviv: Connection with Amazon EC2
1. Open a terminal and change to directory where is located the key-pair.pem file.
2. `ssh -i ./my-key-pair.pem ec2-user@ec2-35-167-131-202.us-west-2.compute.amazonaws.com`
3. `cd/chatbot/backend`

#### Start Konviv API
`pm2 start index.js`

#### Stop Konviv API
`pm2 stop 0` where 0 is the API process id

#### Install a new version of Konviv API (update changes)
1. Stop Konviv API application.
2. Pull the latest changes from master `git pull origin master`
3. Start Konvivi API application.
