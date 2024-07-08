# Certification of registers

It's necessary to create and enlist each individual POS unit/cash register with the CleanCash® Hosted Solution to get them certified as per the legislations in Sweden. 

## Create CleanCash registration number

1. From the Case System, search for **Unique CleanCash Register No.**, and click it to open the table in which the POS units are recorded.     
2. Add a new line if the register you need isn't listed in the table.
3. Provide the following information:   
   - **Contact No.** - the customer number from the case system
   - **Contact Location** - the location of the shop
   - **Contact POS Unit No.** - the POS unit number from Business Central
   - **No. Series** - needs to be set to *CLEANCASH* to ensure that unique CleanCash register numbers are going to be retrieved
   - **CleanCash Register No.** - created automatically when all preceding values are already set; it's value **shouldn't be changed**, but if it is - it needs to be unique, and needs to start with *NP*, since it needs to be sent together with the organization's number, and recognized by Retail Innovation.

    **NOTE:**
    The organization number isn't located in this table, but can be found in the customer's master card. 

   - **CleanCash Unit No.** - provided by Retail Innovation, and filled out after registration at Retail Innovation
   - **URL** - provided by Retail Innovation after registration; required in the POS unit setup process in Business Central

    **NOTE:**
    It's important that all fields are correctly populated. Some fields can't be populated before receiving a registration email from Retail Innovation.

## Register CleanCash® Registration No. At Retail Innovation

1. Send details of the cash register to Retail Innovation, i.e. the supplier of the hosted controller (commonly referred to as "the box").    
   Once the details are created in the Case System, the new **CleanCash Register No.** can't be used without previously being registered and certified by Retail Innovation.
2. If you're the person in charge of the registration, you need to apply the following information to the registration form:

- **Organization's No.** (VAT number)
- **CleanCash Register No.** for all registers that need to be created (from the Case System)
- Registration **Starting Date**
  
  **NOTE:** 
  All three fields in this table need to be populated correctly.

3. Locate the following template in **SharePoint** > **Shared Documents** > **Interne documenter** > **CleanCash**:    
   *Template_created_new_CleanCash_register_no.docx*
4. Send the registration form to *register@retailinnovation.se*.     
   Retail Innovation will create the register within the next 48 hours. Once the **CleanCash Register No.** is registered by Retail Innovation, you will receive a confirmation email.
5. Navigate back to the Case System, and fill out the missing information provided by Retail Innovation:
   - **Unique CleanCash Register No.**
   - **URL**

    **NOTE:**
    Bear in mind that URLs can be different, even within the same shop. Retail Innovation uses more than one server to handle CleanCash.

6. Contact Hosting to create a Service Contract for the new register.    
   There is a chance that it's necessary to update a customer's existing service contract. 