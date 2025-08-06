# Clinical Information System (Database Design)

## About This Project
A structured SQL database schema for a Clinical Information System designed to manage consultations, treatments, laboratory tests, products, and payment processing in a clinic. This project includes comprehensive table structures, stored procedures, functions, triggers, and initial data population to simulate real-world clinical workflows.

## Tech Stack & Tools
| Category     | Stack                        |
|--------------|------------------------------|
| Database     | MySQL / MariaDB               |
| Management   | phpMyAdmin                    |
| Language     | SQL (DDL, DML, Stored Procedures) |

## Key Features
- Table designs covering Doctors, Patients, Products, Treatments, Consultations, and Shifts.
- Stored Procedures for calculating consultation costs, stock management, and payment updates.
- Functions for utility operations like age calculation, stock checking, and price calculations.
- Triggers to automate logging and updating of related data on insert/update actions.
- Predefined Views for easier reporting (consultation details, unpaid consultations, etc.).
- Sample dataset to simulate clinic operations.

## Live Demo
This project is a database-only design. You can import the SQL dump to a local MySQL/MariaDB server to explore.

## Installation and Usage (Local Setup)
1. Open your local MySQL client or phpMyAdmin.
2. Import the provided SQL dump:
    ```sql
    SOURCE klinik_final.sql;
    ```
3. The database `klinik_final` will be created with all tables, procedures, functions, triggers, and initial data.
4. You can run queries and simulate operations like:
    - Calling procedures: `CALL hitungTotalBiaya(1);`
    - Testing triggers by inserting consultation data.
    - Viewing reports from predefined views.

## Future Improvements
- [ ] Add relational integrity constraints (FK constraints) explicitly.
- [ ] Design an application layer to interface with this database (Laravel, Flask, etc.).
- [ ] Implement audit trail enhancements for better activity logging.
- [ ] Normalize product categorization for advanced inventory management.
- [ ] Add more complex business logic for billing scenarios (discounts, insurance).

## Contact & Collaboration
Interested in collaborating or enhancing this project?
Reach me at [LinkedIn](https://linkedin.com/in/dodevca) or visit [dodevca.com](https://dodevca.com).

## Signature
Initiated by **Dodevca**, open for collaboration and continuous refinement.
