# Set up NP Retail fiscalization compliance - Germany

This article details how to configure NP Retail for compliance in Germany.

1. Reach out to NaviPartner for the account details created for your company at Fiskaly.

2. Go to **POS Audit Profiles** page and create one audit profile. Use it for all POS units.

3. For the POS audit profile created: activate the **Audit Log Enabled** option, set the **Fill Sale Fiscal No. On** field value to _Successful Sales_, and select _Fiskaly_ as the **Audit Handler**.     
   This will automatically block the opening of the POS on that POS Unit if any other setup is non-compliant. 

4. On the **POS Audit Profile** page click **Additional Audit Setup**.     
   The **DE Fiskaly POS Unit Setup** page is displayed.

5. On the **DE Fiskaly POS Unit Setup** page:
    - Create a separate record for each POS unit you have. For each POS unit you'll need to specify **Cash Register Brand**, **Cash Register Model**, **Serial Number**, as well as a **TSS Code**.
        >[!Note]
        > You'll need to create the TSS (technical security system) code first. Refer to subsection [_<u>Create technical security systems (TSS)</u>_](#create-technical-security-systems-tss) on how to do that.

    - Click **Create Fiskaly Client** for each record you have set up on the page. The system will connect to Fiskaly, and register the POS unit with them as a Fiskaly client. After the process is completed, each record registered at Fiskaly on the page will have the **Fiskaly Client Created at** and **Last Known Fiskaly Client State** fields automatically filled in.

    - Set up payment method mappings. To do that, click **Payment Method Mapping**, and on the **Payment Method Mapper** page create an entry for each payment method.

    - Set up VAT posting setup mappings. To do that, click **VAT Posting Setup Mapping**, and on the **VAT Post Group Mapper List** page create an entry for each combination of the VAT product and VAT business posting groups.


## Next steps

### Create technical security systems (TSS)

1. On the **DE Fiskaly POS Unit Setup** use the *Look up value* function of the **TSS Code** field to open the **DE Technical Security Systems** page.

2. On the **DE Technical Security Systems** page create at least one TSS.
    >[!Note]
    > It is required that you set up a separate TSS for each physical store. On the other hand, all POS units of the same store can have the same TSS assigned.

3. For each TSS you'll need to specify a **Connection Parameter Set Code**.
    >[!Note]
    > You'll need to create the **Connection Parameter Set Code** first. Refer to the [_<u>Creating connection parameter sets</u>_](#creating-connection-parameter-sets) subsection on how to do that.

4. Click **Create Fiskaly TSS** for each record you have set up on the page. The system will connect to Fiskaly, and register the TSS with them. After the process is completed, each record registered at Fiskaly on the page will have the **Fiskaly TSS Created at** and **Last Known Fiskaly State** fields automatically filled in, as well as **TSS Admin PUK** and **TSS Admin PIN** assigned.
    >[!Note]
    > You can skip this step. The system will check whether the TSS is registered at Fiskaly, and run the process automatically whenever the function **Create Fiskaly Client** is run on the **DE Fiskaly POS Unit Setup** page.


### Creating connection parameter sets

1. On the **DE Technical Security Systems** use the *Look up value* function of the **Connection Parameter Set Code** field to open the **DE Connection Parameter Sets** page.

2. On the **DE Connection Parameter Sets** page create a distinct record for each Fiskaly account (connection parameter set) you've received from NaviPartner.

3. For each connection parameter set record you'll need to specify values for the following fields:
    - **Code** - a unique identifier of the connection parameter set.
    - **Description** - a short description of the connection parameter set.
    - **Fiskaly API URL** - use `https://kassensichv-middleware.fiskaly.com/api/v2` if not instructed overwise.
    - **Api Key** - an API key (a text string), provided by NaviPartner.
    - **Api Secret** - an API secret (a text string), provided by NaviPartner.
