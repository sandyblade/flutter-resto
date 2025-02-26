# Mobile Point Of Sales Restaurant

<p>
  A Mobile POS system in a restaurant acts as the central hub for managing orders, payments, and customer data. 
  It connects the front-of-house (where customers place orders) with the back-of-house (kitchen or bar), ensuring smooth operations.
</p>

<ul>
   <li>Customer Interaction: A waiter or cashier inputs the order into the POS.</li>
   <li>Order Routing: The system sends the order to the correct section (e.g., a kitchen printer or kitchen display system for food, and a bar printer for drinks).</li>
   <li>Accepts cash, credit cards, digital wallets, or split payments.</li>
   <li>Integrates with payment gateways to process card transactions securely.</li>
   <li>Tracks tips and change for accurate cash flow.</li>
   <li>Captures every sale and generates reports for revenue, most popular items, and busiest times.</li>
   <li>Helps owners make data-driven decisions (e.g., removing unpopular menu items).</li>
</ul>

<p>For Online Demo : <a target="_blank" href="https://appetize.io/app/b_7xj7ume65ulqga26fpxfsdr32a">https://appetize.io/app/b_7xj7ume65ulqga26fpxfsdr32a</a></p>

# Preview

<img height="650" src="https://5an9y4lf0n50.github.io/demo-images/pos-resto/2025-01-16%2020-41-13%20High%20Res%20Screenshot%20(2).png" alt="home" />


# Features

<ol type="1">
	<li>
		Authentication
		<ol type="1">
			<li>Login</li>
			<li>Register</li>
			<li>Forgot Password</li>
			<li>Reset Password</li>
		</ol>
	</li>
	<li>
		User Account
		<ol type="1">
			<li>Change Password</li>
			<li>Manage Profile</li>
		</ol>
	</li>
	<li>
		General Page
		<ol type="1">
			<li>Home</li>
			<li>Menu Catalog</li>
			<li>Menu Detail Page</li>
			<li>Order Menu</li>
			<li>Checkout Process</li>
		</ol>
	</li>
</ol>

# Technologies Used

<ol type="1">
	<li>Visual Studio Code</li>
	<li>Flutter SDK</li>
	<li>Android or IOS SDK with Emulator</li>
	<li>Android Studio Or XCode</li>
	<li>Modern Web Browser</li>
	<li>Git 2.4</li>
	<li>
		Backend Technologies
		<ol type="1">
			<li>Mongo DB</li>
			<li>Node JS LTS</li>
			<li>Express JS for REST API </li>
		</ol>
	</li>
	<li>Flutter</li>
</ol>

## Getting Started
#### 1. Clone the repository and navigate to the directory
```shell
git clone https://github.com/sandyblade/flutter-resto.git
cd flutter-resto
```

#### 2. Install backend dependencies, please move to directory flutter-resto/backend
```shell
npm install -g @ionic/cli
npm install nodemon -g
npm install
```

#### 3. Make a .env file and customize its settings 
```shell
APP_ENV=development
APP_TIMEZONE=Asia/Jakarta
JWT_KEY=
DB_DSN=mongodb://admin:password@localhost:27017/db
```

#### 4. Start MongoDB Service and Running REST API
```shell
# in Windows
net start MongoDB

# in Linux
sudo systemctl start mongod
sudo systemctl enable mongod

# create database
mongosh
use my_database


# running backend services
nodemon
```

#### 5. Install frontend dependencies, please move to directory flutter-resto/frontend
```shell
npm install
```

#### 6. Make a .env.local file and customize its settings 
```shell
APP_TITLE="Favorite Resto"
APP_BACKEND_URL=http://localhost:3000
```

#### 7. Run Application 
```shell
cd frontend
flutter run
```

## run flutter run -d chrome to see in web browser


<strong>To login in application, please use these credential : </strong> </br>
email : admin@administrator.example.com </br>
password : Qwerty12345#! </br>


#### 8. Access application by entering [https://localhost:59845](https://localhost:59845) in the browser.

<img height="650" src="https://5an9y4lf0n50.github.io/demo-images/pos-resto/2025-01-16%2020-40-18%20High%20Res%20Screenshot.png" alt="login" />
<br/>
<img height="650" src="https://5an9y4lf0n50.github.io/demo-images/pos-resto/2025-01-16%2020-59-49%20High%20Res%20Screenshot.png" alt="store" />
</br>
<img height="650" src="https://5an9y4lf0n50.github.io/demo-images/pos-resto/2025-01-16%2020-42-40%20High%20Res%20Screenshot.png" alt="product" />
</br>
<img height="650" src="https://5an9y4lf0n50.github.io/demo-images/pos-resto/2025-01-16%2020-42-57%20High%20Res%20Screenshot.png" alt="ordered" />
</br>
<img height="650" src="https://5an9y4lf0n50.github.io/demo-images/pos-resto/2025-01-16%2020-43-09%20High%20Res%20Screenshot.png" alt="checkout"/>
</br>

#### 9. Developer Contact
<ul>
	<li>
		<strong>Whatsapp</strong> <a target="_blank" href="https://wa.me/628989218470">https://wa.me/628989218470</a>
	</li>
	<li>
		<strong>Telegram</strong> <a target="_blank" href="https://t.me/sandyblade">https://t.me/sandyblade</a>
	</li>
	<li>
		<strong>Gmail</strong> <a  href="mailto:sandy.andryanto.blade@gmail.com">sandy.andryanto.blade@gmail.com</a>
	</li>
</ul>