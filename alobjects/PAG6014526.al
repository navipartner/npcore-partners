page 6014526 "Touch Screen - Customers"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPRx.xx/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.23.02/BR /20160623 CASE 244575 Changed PageType from Worksheet to List to enable search box
    // NPR5.26/BHR/20160826 CASE 248133 Enabled default no series
    // NPR5.30/BR  /20170213 CASE 252646 Added function GetViewText
    // NPR5.35/TJ  /20170823 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/TS  /20171115 CASE 296346 Added Address 2

    Caption = 'Touch Screen - Select customer';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = Customer;

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
                field("No.";"No.")
                {
                }
                field(Address;Address)
                {
                }
                field("Address 2";"Address 2")
                {
                }
                field(City;City)
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field(Balance;Balance)
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
                    POSEventMarshaller: Codeunit "POS Event Marshaller";
                    NewPhoneNo: Text;
                    Customer: Record Customer;
                begin
                    //-NPR5.26 [248133]
                    //IF (NOT Marshaller.NumPadText(Text00001,newPhoneNo,FALSE,FALSE)) OR (newPhoneNo = '') THEN
                    if (not POSEventMarshaller.NumPadText(Text00001,NewPhoneNo,false,false)) then
                    //+NPR5.26 [248133]
                      exit;
                    //-NPR5.26 [248133]
                    //INIT;
                    //VALIDATE("No.", newPhoneNo);
                    //INSERT(TRUE);
                    Customer.Init;
                    if NewPhoneNo <> '' then
                      Customer.Validate("No.",NewPhoneNo);
                    Customer.Insert(true);
                    //+NPR5.26 [248133]
                    Commit;
                    //-NPR5.26 [248133]
                    Get(Customer."No.");
                    //+NPR5.26 [248133]
                    PushCard;
                end;
            }
        }
    }

    var
        SearchType: Option Number,Name,Phone;
        LookUpOk: Boolean;
        Text00001: Label 'Create new customer';

    procedure DefSelection(var GLAccount: Record "G/L Account")
    begin
        //CurrForm.SETSELECTIONFILTER(FinKto);
    end;

    procedure GetSelectionFilter(): Code[80]
    var
        GLAccount: Record "G/L Account";
        FirstAccNo: Text[20];
        LastAccNo: Text[20];
        SelectionFilter: Code[80];
        GLAccCount: Integer;
        More: Boolean;
    begin
        //CurrForm.SETSELECTIONFILTER(FinKto);
        GLAccCount := GLAccount.Count;
        if GLAccCount > 0 then begin
          GLAccount.Find('-');
          while GLAccCount > 0 do begin
            GLAccCount := GLAccCount - 1;
            GLAccount.MarkedOnly(false);
            FirstAccNo := GLAccount."No.";
            LastAccNo := FirstAccNo;
            More := (GLAccCount > 0);
            while More do
              if GLAccount.Next = 0 then
                More := false
              else if not GLAccount.Mark then
                More := false
              else begin
                LastAccNo := GLAccount."No.";
                GLAccCount := GLAccCount - 1;
                if GLAccCount = 0 then
                  More := false;
              end;
            if SelectionFilter <> '' then
              SelectionFilter := SelectionFilter + '|';
            if FirstAccNo = LastAccNo then
              SelectionFilter := SelectionFilter + FirstAccNo
            else
              SelectionFilter := SelectionFilter + FirstAccNo + '..' + LastAccNo;
            if GLAccCount > 0 then begin
              GLAccount.MarkedOnly(true);
              GLAccount.Next;
            end;
          end;
        end;
        exit(SelectionFilter);
    end;

    procedure GetItemNo() ItemNo: Code[21]
    begin
        exit("No.");
    end;

    procedure Scroll(No: Integer)
    begin
        if Next(No) > 0 then;
        //CurrForm.UPDATE(FALSE);
    end;

    procedure InitFindAccount()
    begin
        Reset;
    end;

    procedure PushCard()
    var
        CustomerCard: Page "Customer Card";
    begin
        Clear(CustomerCard);
        CustomerCard.SetRecord(Rec);
        // formCard.LOOKUPMODE := TRUE;
        if CustomerCard.RunModal = ACTION::OK then begin
          CustomerCard.GetRecord(Rec);
          //CurrForm.UPDATE(FALSE);
          LookUpOk := true;
          //CurrForm.CLOSE;
        end;
        CustomerCard.GetRecord(Rec);
        //CurrForm.UPDATE(FALSE);
    end;

    procedure SearchFor()
    var
        SearchBoxResult: Text[30];
        SearchBoxResultFilter: Text[250];
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        Txt001: Label 'Searching "Search Name" is limited to maximum 30 chars';
        Txt002: Label 'Search form';
        Txt003: Label 'Searching "No." is limited to maximum 20 chars';
    begin
        //Searchfor

        case SearchType of
          SearchType::Name:
            begin
              SearchBoxResult := CopyStr(POSEventMarshaller.SearchBox(Txt002,Txt001,MaxStrLen(SearchBoxResult)),1,30);
              if SearchBoxResult <> '<CANCEL>' then begin
                SetCurrentKey("Search Name");
                SearchBoxResultFilter := '*@'+ SearchBoxResult + '*';
                SetFilter("Search Name",'%1',SearchBoxResultFilter);
                if Count = 0 then
                  SetRange("Search Name");
              end else begin
                SetRange("Search Name");
              end;
            end;
          SearchType::Number:
            begin
              if POSEventMarshaller.NumPadText(Txt003,SearchBoxResult,false,false) then begin
                SetCurrentKey("Primary Key Length");
                SetRange("No.",SearchBoxResult);
                if Count = 0 then
                  SetRange("No.");
              end else
                SetRange("No.");
            end;
        end;
    end;

    procedure GetLookUpOk(): Boolean
    begin
        exit(LookUpOk);
    end;

    procedure GetViewText(): Text
    begin
        //-NPR5.30 [252646]
        exit(Rec.GetView(false));
        //+NPR5.30 [252646]
    end;
}

