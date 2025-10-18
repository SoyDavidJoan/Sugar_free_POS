# Requirements

## Functional Requirements

### User Management
1. The system must create an admin user (superuser) before completing the installation process.
2. The system must allow creating, modifying, and deleting users and their permissions.
   - (User roles and permissions will be detailed in the "Design" document.)

### Inventory Management
3. The system must allow creating different product categories.
4. The system must allow adding new products.
5. The system must allow selecting the tax type for each product: **IVA**, **Exempt from IVA**, or **0% rate**.
6. The system must allow creating different types of inventory entries.
7. The system must allow recording product entries from different origins (e.g., purchase, gift from supplier, etc.).
8. The system must allow defining different types of product outputs (e.g., losses, gifts, expired products, etc.).
9. The system must allow registering product outputs using those predefined types and automatically deduct the corresponding quantity from the inventory.
10. The system must allow tracking all product movements (entries and outputs).
11. The system must allow viewing the movement history of any product.
12. The system must allow printing a report of the current stock (inventory list).

### Sales
13. The system must allow searching products by barcode or product name.
14. The system must allow performing the sales process and generating receipts.
15. The system must allow viewing the sales history.
16. The system must allow reprinting previous receipts.
17. The system must allow cash closing operations (total sales, totals per payment method, total cash in register).
18. The system must allow payments with different payment methods.
19. The system must allow combining two or more payment methods in a single sale.
20. The system must allow canceling sales.

## Non-Functional Requirements
1. The system must include a simple installer.
2. The system should run offline.
3. The interface should be simple and intuitive.
4. Data must be saved automatically after each operation.
5. The application should run on Windows 10+ without external dependencies.
6. The system should calculate totals automatically.
7. The system should store all data in a local SQLite database.
8. The system should automatically create a daily backup of the database.

## Future Functions
1. The system must allow defining a percentage of profit for each product.
2. The system must allow automatically updating the product price based on the profit percentage and the cost of the last entry.
