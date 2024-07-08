report 6014512 "NPR MMM Notification Entry"
{
    Caption = 'MM Member Notification Entry';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    DataAccessIntent = ReadOnly;

#if not (BC17 or BC18 or BC19)
    DefaultRenderingLayout = "Word Layout";
#else
    DefaultLayout = Word;
    WordLayout = './src/_Reports/layouts/MMMNotificationEntry.docx';
#endif

    dataset
    {
        dataitem("NPR MM Member Notific. Entry"; "NPR MM Member Notific. Entry")
        {
            column(Notification_Code; "Notification Code") { }
            column(Date_To_Notify; "Date To Notify") { }
            column(Notification_Trigger; "Notification Trigger") { }
            column(Template_Filter_Value; "Template Filter Value") { }
            column(Coupon_Reference_No; "Coupon Reference No.") { }
            column(Coupon_Discount_Type; "Coupon Discount Type") { }
            column(Coupon_Discount_Percent; "Coupon Discount %") { }
            column(Coupon_Discount_Amount; "Coupon Discount Amount") { }
            column(Coupon_Starting_Date; "Coupon Starting Date") { }
            column(Coupon_Ending_Date; "Coupon Ending Date") { }
            column(Coupon_Description; "Coupon Description") { }
            column(Target_Member_Role; "Target Member Role") { }
            column(Notification_Method; "Notification Method") { }
            column(External_Member_No; "External Member No.") { }
            column(Customer_No; "Customer No.") { }
            column(Contact_No; "Contact No.") { }
            column(External_Membership_No; "External Membership No.") { }
            column(E_Mail_Address; "E-Mail Address") { }
            column(Phone_No; "Phone No.") { }
            column(First_Name; "First Name") { }
            column(Middle_Name; "Middle Name") { }
            column(Last_Name; "Last Name") { }
            column(Display_Name; "Display Name") { }
            column(Address; Address) { }
            column(Post_Code; "Post Code Code") { }
            column(City; City) { }
            column(Country_Code; "Country Code") { }
            column(Country; Country) { }
            column(Birthday; Birthday) { }
            column(Community_Code; "Community Code") { }
            column(Membership_Code; "Membership Code") { }
            column(Item_No; "Item No.") { }
            column(Membership_Valid_From; "Membership Valid From") { }
            column(Membership_Valid_Until; "Membership Valid Until") { }
            column(Community_Description; "Community Description") { }
            column(Membership_Description; "Membership Description") { }
            column(Membership_Consecutive_From; "Membership Consecutive From") { }
            column(Membership_Consecutive_Until; "Membership Consecutive Until") { }
            column(External_Member_Card_No; "External Member Card No.") { }
            column(Card_Valid_Until; "Card Valid Until") { }
            column(Pin_Code; "Pin Code") { }
            column(Auto_Renew; "Auto-Renew") { }
            column(Auto_Renew_Payment_Method_Code; "Auto-Renew Payment Method Code") { }
            column(Auto_Renew_External_Data; "Auto-Renew External Data") { }
            column(Remaining_Points; "Remaining Points") { }
            column(Notification_Token; "Notification Token") { }
            column(Failed_With_Message; "Failed With Message") { }
            column(Include_NP_Pass; "Include NP Pass") { }
            column(Wallet_Pass_Id; "Wallet Pass Id") { }
            column(Wallet_Pass_Default_URL; "Wallet Pass Default URL") { }
            column(Wallet_Pass_Andriod_URL; "Wallet Pass Andriod URL") { }
            column(Wallet_Pass_Landing_URL; "Wallet Pass Landing URL") { }
            column(Magento_Get_Password_URL; "Magento Get Password URL") { }
            column(ClientSignUpUrl; ClientSignUpUrl) { }
            column(AzureRegistrationSetupCode; AzureRegistrationSetupCode) { }
            column(DataSubjectId; DataSubjectId) { }
        }
    }
#if not (BC17 or BC18 or BC19)
    rendering
    {
        layout("Word Layout")
        {
            Type = Word;
            Caption = 'Word layout.';
            LayoutFile = './src/_Reports/layouts/MMMNotificationEntry.docx';
        }
    }
#endif
}