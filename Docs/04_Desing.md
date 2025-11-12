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
