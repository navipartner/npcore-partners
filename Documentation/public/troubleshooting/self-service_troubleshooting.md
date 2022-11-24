# POS Self-Service Profile troubleshooting

#### My self-service configuration doesn't work properly. What can I do to fix it?

It's important to check whether all the necessary steps have been taken in the correct order to establish the effective self-service feature setup. Go through the provided checklist to see if something is missing:

1. Create a **POS Store**.   
   This step is optional, depending on locations, the posting setup, etc. 
2. Create a **POS Unit**.      
   - Set the **POS Type** to **Unattended**.
3. Configure the **POS View Profile**.   
   - The **After End-of-Sale View** needs to be set to **Login View**. 
   - The **POS Theme** is optional.
4. Configure the **POS End of Day Profile**.    
   - The **Master & Slave** setup is required. 
   - The master POS unit needs to be identified. 
   - Both master and slave should have the same POS EOD profile. 
5. Configure the **POS Named Actions Profile**.   
   - Add the SS-POS where necessary. 
   - Provide the number of seconds after which the timeout occurs. 
6. Make sure that the same bin as the main one is used in the **POS Payment Bin**.
7. Define the **POS View** for the screen layout.   
   - If you're using a picture as a banner, insert it in the JSON file. 
   - Perform the timeout setup in the JSON. 
   - Optionally configure the special SS features like the cart view, plus/minus options on the button, and item addon buttons.
8. Define the salespeople for self-service to be used in the POS menus. 
9. Define the languages to be used in the **POS Menus**.
10. Define POS menus to be used within POS views.    
    The POS menus need to contain only SS POS actions. 
11. Define a POS payment method for self-service for EFT.
12. Configure the POS posting setup for the SS payment method. 
13. Specify a POS theme that will be used. 
14. Set up the EFT interface for the payment type SSP (Adyen - EFT).   
    It's not necessary to have a cash facilities machine that is interacted with. 
15. If the payment dialogue from Adyen is white, or has a white background, a fix can be applied.   
    A CSS (FIXCSS.css) file needs to be installed for the payment dialogue from the Terminal T (Adyen). If this fix isn't working, a new CSS file needs to be created.
16. The print template for the ticket with the specific printer format needs to be configured. 
17. Configure Major Tom for self-service. 
18. Configure hardware.    
    - FLEXI Outdoor Kiosk
    - Adyen Payment Terminal
    - Boca Printer 

For full procedure, refer to the [Self-service profile setup](../retail/posunit/howto/pos_self_service_prof.md).