# System Design

<!-- ## Overview
This document describes the architecture and design of Sugar Free POS.
It includes class diagrams and sequence diagrams to explain how the system works. -->

## Overview

This document describes the architecture and design of Sugar Free POS.
It includes class diagrams and sequence diagrams to explain how the system works.

## Architecture

The system follows a simple 3-layer architecture:

- **Presentation Layer**: The UI (Forms or WPF) where users interact with the system.
- **Business Layer**: Contains the logic for sales, inventory, user management, and validation.
- **Data Layer**: Responsible for database access (SQLite) via repositories.

## Class Diagram

![Class Diagram](./img/Class_diagram.png)

---

```mermaid
---
title: Sugar free POS Class Diagram
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
        +Date dateSale
        +Double subtotal
        +Double iva
        +Double total
        +Boolean status
        +calcTotal()
    }
    class SalesDetail {
        +Double quantity
        +Double cost
        +Double price
        +Double iva
        +reduceStock()
        +calcPrice()
    }
    class Product {
        +String name
        +String barcode
        +Double price
        +Double cost
    }
    class Payment {
        +Double amount
        +registerPayment()
    }
    class PaymentMethod {
        +String name
    }
    class CashierShift {
        +Date startDate
        +Date endDate
        +Double totalCashSale
        +Double totalCardSale
        +Double totalSale
        +Double totalCashReceive
        +Double totalCardReceive
        +calcTotals()
        +calcTotalCardReceive()
    }
    class CanceledSale {
        +Date canceledDate
        +String reason
        +getSaleDetails()
        +incrementStock()
    }
    class Entry {
        +Date entryDate
    }
    class EntryDetail {
        +Double quantity
        +Double cost
        +incrementStock()
        +updateCostProduct()
    }
    class OutputDetail {
        +Double cost
        +reduceStock()
    }
    class Output {
        +Date outputDate
    }
    class Category {
        +String name
        +String description
    }
    class UnitMeasure {
        +String name
        +String symbol
    }
    class TaxType {
        +String name
        +Double rate
    }
    class EntryType {
        +String name
        +String description
    }
    class OutputType {
        +String name
        +String description
    }


    Supervisor --|> User
    Cashier --|> User
    Cashier "1" --* "*" Sale
    Sale "1" --* "*" SalesDetail
    SalesDetail --o Product
    Sale "1" --* "*" Payment
    Payment --o PaymentMethod
    CashierShift "1" --* "*" Sale
    Cashier "1" --* "*" CashierShift
    Sale "1" --* "0..1" CanceledSale
    Entry "1" --* "*" EntryDetail
    EntryDetail --o Product
    Output "1" --* "*" OutputDetail
    OutputDetail --o Product
    Product "*" --o "1" Category
    Product "*" --o "1" UnitMeasure
    Product "*" --o "1" TaxType
    Entry "*" --o "1" EntryType
    Output "*" --o "1" OutputType
```

## Sequence diagrams

### Login

![Login Sequence Diagram](./img/Login_sequence_diagram.png)

```mermaid
---
title: Login Sequence diagram
---

sequenceDiagram
  actor User as User
  participant POS as POS
  participant DB as DB

  User ->> POS: Inputs username and password
  POS ->> DB: Validate credentials
  alt Valid credentials
    DB -->> POS: Credentials OK
    POS -->> User: Displays welcome message
  else Invalid credentials
    DB -->> POS: Invalid credentials
    POS -->> User: Displays error message
    loop Retry login
      User ->> POS: Re-enter username and password
    end
  end
```

### Sales

![Login Sequence Diagram](./img/Sale_sequence_diagram.png)

```mermaid
---
title: Sale Sequence diagram
---

sequenceDiagram
  actor User as User
  participant POS as POS
  participant DB as DB
  participant Printer as Printer

  loop Scan Products
    User ->> POS: Scan product
    POS ->> DB: Validate product and stock
    alt Product available
      DB -->> POS: Product ok
      POS ->> POS: Add to SaleDetail
      POS ->> POS: Update sale subtotal, taxes and total
    else Product not available
      DB -->> POS: Not available
      POS -->> User: Display error message
    end
  end

  opt Review Sale
    loop Remove items
      User ->> POS: Remove item
      POS ->> POS: Update SaleDetail
      POS ->> POS: Recalculate subtotal, taxes and total
    end
  end

  POS -->> User: Show total of sale
  loop Add payments 
    User ->> POS: Add payment method
    POS ->> POS: Update total paid
  end

  alt Payment complete
      POS ->> DB: Record sale and sale details
      POS ->> DB: Record payments
      POS ->> DB: Reduce stock for each sale detail

      critical Commit sale
        alt Commit OK
            DB -->> POS: Commit OK
            POS ->> Printer: Print ticket
            POS -->> User: Show change
        else Commit Error
            DB ->> DB: Rollback
            DB -->> POS: Commit error
            POS -->> User: Display error message
        end

      end  
  else Payment incomplete
    POS -->> User: Unable to continue
  end
```

### Product Entries

![Entry Sequence Diagram](./img/Entry_sequence_diagram.png)

```mermaid
---
title: Product Entry Sequence diagram
---
sequenceDiagram
  actor User as User
  participant POS as POS
  participant DB as DB
  loop Scan Products
    User ->> POS: Scan/select product + quantity
    POS ->> DB: Validate product
    alt Product available
      DB -->> POS: Product ok
      POS ->> POS: Add to entry detail
    else Product not available
      DB -->> POS: Not available
      POS -->> User: Display error message
    end
  end
  opt Review Entry
    loop Remove items
      User ->> POS: Remove item
      POS ->> POS: Update entry detail
    end
  end
  User ->> POS: Select entry type
  User ->> POS: Confirm entry
  POS ->> DB: Record entry and EntryDetail
  POS ->> DB: Update product stock
  critical Commit entry 
    alt Commit Ok
      DB -->> POS: Commit ok
      POS -->> User: Display sucess message
    else Commit error
      DB ->> DB: Rollback
      DB -->> POS: Commit error
      POS -->> User: Display error message
    end
  end
```

### Product Outputs

![Outputs Sequence Diagram](./img/Output_sequence_diagram.png)

```mermaid
---
title: Product Output Sequence diagram
---
sequenceDiagram
  actor User as User
  participant POS as POS
  participant DB as DB
  loop Scan Products
    User ->> POS: Scan/select product + quantity
    POS ->> DB: Validate product and stock
    alt Product available
      DB -->> POS: Product ok
      POS ->> POS: Add to output detail
    else Product not available
      DB -->> POS: Not available
      POS -->> User: Display error message
    end
  end
  opt Review Output
    loop Remove items
      User ->> POS: Remove item
      POS ->> POS: Update output detail
    end
  end
  User ->> POS: Select output type
  User ->> POS: Confirm output
  POS ->> DB: Record output and OutputDetail
  POS ->> DB: Reduce product stock
  critical Commit Output 
    alt Commit Ok
      DB -->> POS: Commit ok
      POS -->> User: Display success message
    else Commit error
      DB ->> DB: Rollback
      DB -->> POS: Commit error
      POS -->> User: Display error message
    end
  end
```

![Cancel sale sequence Diagram](./img/Cancel_sale_sequence_diagram.png)

```mermaid
---
title: Cancel Sale Sequence diagram
---
sequenceDiagram
  actor User as User
  participant POS as POS
  participant DB as DB
  User ->> POS: Search for the sale
  POS ->> DB: Validate user permission
  alt User has permission
    DB -->> POS: Permission granted
    POS ->> DB: Fetch sale data
  else User doesn't have permission
    DB -->> POS: Deny permission
    POS -->> User: Permission denied
  end
  alt Sale exists
    DB -->> POS: Sale information
    POS -->> User: Display sale information
  else Sale doesn't exist
    DB -->> POS: Sale not found
    POS -->> User: Display error message
  end
  User ->> POS: Start cancellation
  POS ->> DB: Validate sale eligibility
  alt Sale eligible to cancel
    DB -->> POS: Eligible to cancel
    POS -->> User: Request cancellation reason
  else Sale not eligible
    DB -->> POS: Not eligible
    POS -->> User: Display error message
  end
  User ->> POS: Confirm cancellation
  POS ->> DB: Mark sale as canceled
  POS ->> DB: Update stock for each sale detail
  POS ->> DB: Register the cancellation record
  critical Commit cancellation
    alt Commit ok
      DB -->> POS: Commit success
      POS -->> User: Display success message
      POS -->> User: Display refund amount to return to client
    else Commit error
      DB ->> DB: Rollback
      DB -->> POS: Commit error
      POS -->> User: Display error message
    end
  end
```
