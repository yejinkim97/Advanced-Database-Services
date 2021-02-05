#include <iostream>
#include <string>
#include <occi.h>

// https://docs.oracle.com/cd/B10501_01/appdev.920/a96583/cci02rel.htm
// https://docs.oracle.com/cd/B28359_01/appdev.111/b28390/reference030.htm#LNCPP1022
using oracle::occi::Environment;
using oracle::occi::Connection;
using namespace oracle::occi;
using namespace std;

struct ShoppingCart
{
	int product_id;
	double price;
	int quantity;
};

int mainMenu()
{
	int chose = 0;
	do
	{
		cout << "*************Main Menu by Kim ********************\n"
			<< "1)\tLogin\n"
			<< "0)\tExit\n";

		if (chose != 0 && chose != 1)
		{
			cout << "You entered a wrong value. Enter an option (0-1): ";
		}
		else
			cout << "Enter an option (0-1): ";

		cin >> chose;
	} while (chose != 0 && chose != 1);

	return chose;
}

int customerLogin(Connection* conn, int customerId)
{
	//Callable Statements
	Statement* stmt = conn->createStatement();
	stmt->setSQL("BEGIN find_customer(:1, :2); END;");
	int id;
	stmt->setInt(1, customerId); // value for first parameter=cusromerId
	stmt->registerOutParam(2, Type::OCCIINT, sizeof(id));// specify the type and size of the second (OUT) parameter
	stmt->executeUpdate(); //// call the procedure
	id = stmt->getInt(2); //// get the value of the second (OUT) parameter
	conn->terminateStatement(stmt);

	return id;
}

double findProduct(Connection* conn, int product_id);

int addToCart(Connection* conn, struct ShoppingCart cart[])
{
	cout << "-------------- Add Products to Cart --------------" << endl;
	int i = 0;
	while (i < 5)
	{
		int pro_id;
		int pro_qty;
		ShoppingCart list;
		int chose;

		do
		{
			cout << "Enter the product ID: ";
			cin >> pro_id;

			if (findProduct(conn, pro_id) == 0)
				cout << "The product does not exist. Try again..." << endl;
		} while (findProduct(conn, pro_id) == 0);

		cout << "Product Price: " << findProduct(conn, pro_id) << endl;
		cout << "Enter the product Quantity: ";
		cin >> pro_qty;

		list.product_id = pro_id;
		list.price = findProduct(conn, pro_id);	
		list.quantity = pro_qty;
		cart[i] = list;

		if (i == 4)
			return i + 1;
		else
		{
			do
			{
				cout << "Enter 1 to add more products or 0 to check out: ";
				cin >> chose;
			} while (chose != 0 && chose != 1);
		}
		if (chose == 0)
			return i + 1;
		++i;
	}
}
double findProduct(Connection* conn, int product_id)
{
	Statement* stmt = conn->createStatement();
	stmt->setSQL("BEGIN find_product(:1, :2); END;");
	double price;
	stmt->setInt(1, product_id);
	stmt->registerOutParam(2, Type::OCCIDOUBLE, sizeof(price));
	stmt->executeUpdate();
	price = stmt->getDouble(2);
	conn->terminateStatement(stmt);

	return price > 0 ? price : 0;
}







void displayProducts(struct ShoppingCart cart[], int productCount)
{
	if (productCount > 0)
	{
		double total = 0;
		cout << "------- Ordered Products ---------" << endl;
		for (int i = 0; i < productCount; ++i)
		{
			cout << "---Item " << i + 1 << endl;
			cout << "Product ID: " << cart[i].product_id << endl;
			cout << "Price: " << cart[i].price << endl;
			cout << "Quantity: " << cart[i].quantity << endl;
			total += cart[i].price * cart[i].quantity;
		}
		cout << "----------------------------------\nTotal: " << total << endl;
	}
}



int checkout(Connection* conn, struct ShoppingCart cart[], int customerId, int productCount)
{
	char chose;
	do
	{
		cout << "Would you like to checkout ? (Y / y or N / n) ";
		cin >> chose;

		if (chose != 'Y' && chose != 'y' && chose != 'N' && chose != 'n')
			cout << "Wrong input. Try again..." << endl;
	} while (chose != 'Y' && chose != 'y' && chose != 'N' && chose != 'n');

	if (chose == 'N' || chose == 'n')
	{
		cout << "The order is cancelled." << endl;
		return 0;
	}
	else
	{

		Statement* stmt = conn->createStatement();
		stmt->setSQL("BEGIN add_order(:1, :2); END;");
		int order_id;
		stmt->setInt(1, customerId);
		stmt->registerOutParam(2, Type::OCCIINT, sizeof(order_id));
		stmt->executeUpdate();
		order_id = stmt->getInt(2);

		for (int i = 0; i < productCount; ++i)
		{
			stmt->setSQL("BEGIN add_orderline(:1, :2, :3, :4, :5); END;");
			stmt->setInt(1, order_id);
			stmt->setInt(2, i + 1);
			stmt->setInt(3, cart[i].product_id);
			stmt->setInt(4, cart[i].quantity);
			stmt->setDouble(5, cart[i].price);
			stmt->executeUpdate();
		}

		cout << "The order is successfully completed." << endl;
		conn->terminateStatement(stmt);

		return 1;
	}
}
int main()
{
	/* OCCI Variables */
	Environment* env = nullptr;
	Connection* conn = nullptr;
	/* User Variables */
	string str;
	string user = "dbs311_203e17";
	string pass = "14987606";
	string constr = "myoracle12c.senecacollege.ca:1521/oracle12c";
	try
	{
		/* ----- create connection -----*/
		env = Environment::createEnvironment(Environment::DEFAULT);
		conn = env->createConnection(user, pass, constr);
		cout << "Connection is Successful!\n\n" << endl;

		/* ----- tasks -------*/
		int chose;
		int customerId;
		do
		{
			chose = mainMenu();

			if (chose == 1)
			{
				cout << "Enter the customer ID: ";
				cin >> customerId;

				if (customerLogin(conn, customerId) == 0)
				{
					cout << "The customer does not exist." << endl;
				}
				else
				{
					ShoppingCart cart[5]; //purchase up to five items in one order. 
					int count = addToCart(conn, cart);
					displayProducts(cart, count);
					checkout(conn, cart, customerId, count);
				}
			}
		} while (chose != 0);
		cout << "Good bye!..." << endl;
		env->terminateConnection(conn);
		Environment::terminateEnvironment(env);
	}
	catch (SQLException& sqlExcp)
	{
		cout << sqlExcp.getErrorCode() << ":" << sqlExcp.getMessage();
	}
	return 0;
}
