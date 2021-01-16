page 6014524 "NPR Touch Screen: CRM Contacts"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPRx.xx/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.30/BHR/20170308 CASE 267123 Action NEw to create new contact
    // NPR5.36/TS  /20170904/  CASE 288808 Change Page Typeto List instead of Card.

    Caption = 'Contact List';
    CardPageID = "Contact Card";
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Contact;

    layout
    {
        area(content)
        {
            repeater(Control6150621)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Mobile Phone No."; "Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mobile Phone No. field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(New)
            {
                Caption = 'New';
                Image = NewCustomer;
                Promoted = true;
                PromotedCategory = New;
                ApplicationArea = All;
                ToolTip = 'Executes the New action';

                trigger OnAction()
                var
                    // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
                    //Marshaller: Codeunit "POS Event Marshaller";
                    newPhoneNo: Text;
                    formCard: Page "Customer Card";
                    contact: Record Contact;
                begin
                    //-NPR5.30 [267123]
                    // TODO: CTRLUPGRADE - Must be refactored without Marshaller
                    Error('CTRLUPGRADE');
                    /*
                    if (not Marshaller.NumPadText(Text00001, newPhoneNo, false, false)) then
                        exit;
                    */
                    contact.Init;
                    if newPhoneNo <> '' then
                        contact.Validate("No.", newPhoneNo);
                    contact.Insert(true);
                    Commit;
                    Get(contact."No.");
                    pushCard;
                    //-NPR5.30 [267123]
                end;
            }
        }
    }

    var
        Cont: Record Contact;
        utility: Codeunit "NPR Utility";
        searchType: Option Number,Name,Phone;
        bLookupOk: Boolean;
        Text00001: Label 'Create new contact';

    procedure pushCard()
    var
        formCard: Page "Contact Card";
    begin
        //pushCard

        Clear(formCard);
        formCard.LookupMode(true);
        formCard.SetRecord(Rec);
        if formCard.RunModal = ACTION::OK then begin
            formCard.GetRecord(Rec);
            CurrPage.Update(false);
            bLookupOk := true;
            CurrPage.Close;
        end;
        formCard.GetRecord(Rec);
        CurrPage.Update(false);
        Get(Rec."No.");
    end;

    procedure LookupOk(): Boolean
    begin
        exit(bLookupOk)
    end;
}

