# System Design

<!-- ## Overview
This document describes the architecture and design of Sugar Free POS.
It includes class diagrams and sequence diagrams to explain how the system works. -->

## Architecture
The system follows a simple 3-layer architecture:
- **Presentation Layer**: The UI (Forms or WPF) where users interact with the system.
- **Business Layer**: Contains the logic for sales, inventory, user management, and validation.
- **Data Layer**: Responsible for database access (SQLite) via repositories.


## Class Diagram
![Class Diagram](./class_diagram.png)

---
title: Sugar free POS
---
classDiagram
direction TB
    class User {
	    +String name
	    +String username
	    +String password
	    +login()
	    +logout()
	    +getPermissions()
	    +watchInventoryHistory()
	    +printCurrentStock()
	    +searchProduct()
	    +watchSaleHistory()
    }
    class Supervisor {
	    +createUser()
	    +updateUser()
	    +deleteUser()
	    +changePermission()
	    +createCategory()
	    +createProduct()
	    +createEntryType()
	    +reprintReceipt()
	    +cancelSale()
    }
    class Cashier {
	    +doSale()
	    +closeShift()
	    +receivePayment()
    }
    class Sale {
	    +Integer id
	    +Date date_sale
	    +Double subtotal
	    +Double iva
	    +Double total
	    +Boolean estatus
      +calcTotal()
    }
    class SalesDetail {
	    +Double quantity
	    +Double cost
	    +Double price
	    +Doubl iva
	    +discountStock()
      +calcPrice()
    }

    Supervisor --|> User
    Cashier --|> User
    Cashier "1" --* "*" Sale
    Sale "1" --* "*" SalesDetail


## Sequence Diagram
![Sequence Diagram](./sequence_diagram.png)
