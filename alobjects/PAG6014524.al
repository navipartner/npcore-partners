page 6014524 "Touch Screen - CRM Contacts"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPRx.xx/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.30/BHR/20170308 CASE 267123 Action NEw to create new contact
    // NPR5.36/TS  /20170904/  CASE 288808 Change Page Typeto List instead of Card.

    Caption = 'Contact List';
    CardPageID = "Contact Card";
    PageType = List;
    SourceTable = Contact;

    layout
    {
        area(content)
        {
            repeater(Control6150621)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("Mobile Phone No.";"Mobile Phone No.")
                {
                }
                field("No.";"No.")
                {
                }
                field(Address;Address)
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
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

                trigger OnAction()
                var
                    Marshaller: Codeunit "POS Event Marshaller";
                    newPhoneNo: Text;
                    formCard: Page "Customer Card";
                    contact: Record Contact;
                begin
                    //-NPR5.30 [267123]
                    if (not Marshaller.NumPadText(Text00001,newPhoneNo,false,false))  then
                      exit;
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
        utility: Codeunit Utility;
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

    procedure searchFor()
    var
        Vare: Record Item;
        tekst30: Text[30];
        tekst250: Text[250];
        Marshaller: Codeunit "POS Event Marshaller";
        t001: Label 'Searching "Search Name" is limited to maximum 30 chars';
        t002: Label 'Search form';
        t003: Label 'Searching "No." is limited to maximum 20 chars';
        t004: Label 'Searching "Phone" is limited to maximum 20 chars';
    begin
        //searchfor

        case searchType of
          searchType::Name :
            begin
              tekst30 := CopyStr(Marshaller.SearchBox(t002,t001,MaxStrLen(tekst30)),1,30);
              if tekst30 <> '<CANCEL>' then begin
                SetCurrentKey("Search Name");
                tekst250 := '*@'+ tekst30 + '*';
                SetFilter("Search Name", '%1', tekst250);
              end else begin
                SetRange("Search Name");
              end;
            end;
          searchType::Number :
            begin
              if Marshaller.NumPadText(t003,tekst30,false,false) then begin
                SetCurrentKey("No.");
                tekst250 := '*@'+ tekst30 + '*';
                SetFilter("No.",'%1',tekst250);
              end else
                SetRange("No.");
            end;
        end;
    end;

    procedure LookupOk(): Boolean
    begin
        exit(bLookupOk)
    end;
}

