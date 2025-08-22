

# E-Commerce Sales Analysis
**Gürmen Teknoloji Internship Assignment

## Description
This project is a relational database design and SQL analysis for an **e-commerce and retail company**. It focuses on **customer data management**, **sales metrics**, **top customer insights**, **product performance**, and **detailed sales reporting**.

The database is designed following **3NF rules** with **primary keys (PK)** and **foreign keys (FK)** for relational integrity. Performance considerations and future scalability are included in the design.

---

## Database
- **Database Name:** \`eticaret\`  
- **Schema:** \`sales\`  
- Stores customer and sales data including invoices, products, and sold products.
<img width="368" height="267" alt="Image" src="https://github.com/user-attachments/assets/0e4610c8-feef-4f2f-9d2b-435f7f20c4ec" />


### Tables

1. **Customer**

\`\`\`sql
CREATE TABLE sales."customer"(
    customer_id INT PRIMARY KEY
);
\`\`\`

2. **Invoice**

\`\`\`sql
CREATE TABLE sales."invoice"(
    invoice_no BIGINT PRIMARY KEY,
    invoice_date TIMESTAMP,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES sales."customer"(customer_id)
);
\`\`\`

3. **Product**

\`\`\`sql
CREATE TABLE sales."product"(
    product_id SERIAL PRIMARY KEY,
    product VARCHAR(200) NOT NULL,
    product_color VARCHAR(200) NOT NULL,
    CONSTRAINT unique_product UNIQUE(product, product_color)
);
\`\`\`

4. **Sold Product**

\`\`\`sql
CREATE TABLE sales."sold_product"(
    invoice_no BIGINT,
    product_id BIGINT,
    quantity INT,
    unit_price NUMERIC(20,10),
    PRIMARY KEY (invoice_no, product_id),
    FOREIGN KEY (invoice_no) REFERENCES sales."invoice"(invoice_no),
    FOREIGN KEY (product_id) REFERENCES sales."product"(product_id)
);
\`\`\`

---

## Usage
1. Create the database and schema:

\`\`\`bash
psql -U <username> -f create_database.sql
\`\`\`

2. Import the SQL dump or run the scripts:

\`\`\`bash
psql -U <username> -d eticaret -f dump-eticaret-202508221031.sql
\`\`\`

3. Run queries in \`queries.sql\` to answer business questions:
- Monthly net sales and quantities
- Top customers by sales and purchase frequency
- Product group performance
- Color and daily sales metrics

---

## Folder Structure

\`\`\`
/sql
    dump-eticaret-202508221031.sql
    queries.sql
    create_database.sql
/ERD
    ecommerce_erd.png
README.md

\`\`\`

---

## Notes
- Replace <username> with your PostgreSQL username.  
- No sensitive customer data is included.  
- Only complete months are considered in the analysis.

---

## License
This project is open for educational and analytical purposes.
EOL
