page 6014690 "NPR User Setup Step"
{
    Caption = 'User Setup';
    PageType = ListPart;
    SourceTable = "User Setup";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(UserSetups)
            {
                field("User ID"; UserId)
                {
                    ApplicationArea = All;
                    Caption = 'User Id';
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';

                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::Users, TempAllUser) = Action::LookupOK then begin
                            UserId := TempAllUser."User Name";
                            Rec."User ID" := TempAllUser."User Name";
                        end;
                    end;
                }
                field("Allow Posting From"; Rec."Allow Posting From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the earliest date on which the user is allowed to post to the company.';
                }
                field("Allow Posting To"; Rec."Allow Posting To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last date on which the user is allowed to post to the company.';
                }
                field("POS Unit Time"; Rec."Register Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to register the user''s time usage defined as the time spent from when the user logs in to when the user logs out. Unexpected interruptions, such as idle session timeout, terminal server idle session timeout, or a client crash are not recorded.';
                }
                field("Salespers./Purch. Code"; SalespersonCode)
                {
                    ApplicationArea = All;
                    Caption = 'Salesperson Code';
                    ToolTip = 'Specifies the code for the salesperson or purchaser for the user.';

                    Lookup = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"NPR Salespers/PurchSelect", TempAllSalesperson) = Action::LookupOK then begin
                            SalespersonCode := TempAllSalesperson.Code;
                            Rec."Salespers./Purch. Code" := TempAllSalesperson.Code;
                        end;
                    end;
                }
                field("Sales Resp. Ctr. Filter"; Rec."Sales Resp. Ctr. Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the responsibility center to which you want to assign the user.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RespCenter: Record "Responsibility Center";
                    begin
                        if Rec."Sales Resp. Ctr. Filter" <> '' then
                            if RespCenter.Get(Rec."Sales Resp. Ctr. Filter") then;

                        if Page.RunModal(Page::"Responsibility Center List", RespCenter) = Action::LookupOK then
                            Rec."Sales Resp. Ctr. Filter" := RespCenter.Code
                    end;
                }

                field("Purchase Resp. Ctr. Filter"; Rec."Purchase Resp. Ctr. Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the responsibility center to which you want to assign the user.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RespCenter: Record "Responsibility Center";
                    begin
                        if Rec."Purchase Resp. Ctr. Filter" <> '' then
                            if RespCenter.Get(Rec."Purchase Resp. Ctr. Filter") then;

                        if Page.RunModal(Page::"Responsibility Center List", RespCenter) = Action::LookupOK then
                            Rec."Purchase Resp. Ctr. Filter" := RespCenter.Code
                    end;
                }
                field("Service Resp. Ctr. Filter"; Rec."Service Resp. Ctr. Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the responsibility center you want to assign to the user. The user will only be able to see service documents for the responsibility center specified in the field. This responsibility center will also be the default responsibility center when the user creates new service documents.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        RespCenter: Record "Responsibility Center";
                    begin
                        if Rec."Service Resp. Ctr. Filter" <> '' then
                            if RespCenter.Get(Rec."Service Resp. Ctr. Filter") then;

                        if Page.RunModal(Page::"Responsibility Center List", RespCenter) = Action::LookupOK then
                            Rec."Service Resp. Ctr. Filter" := RespCenter.Code
                    end;
                }
                field("Time Sheet Admin."; Rec."Time Sheet Admin.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a user is a time sheet administrator. A time sheet administrator can access any time sheet and then edit, change, or delete it.';
                }
                field("NPR POS Unit No."; "NPR POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Backoffice POS Unit No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSUnitsList: Page "NPR POS Units Select";
                    begin
                        POSUnitsList.LookupMode := true;

                        POSUnitsList.SetPOSUnitMode(true);
                        POSUnitsList.SetRec(TempAllPOSUnit);

                        if "NPR POS Unit No." <> '' then
                            if TempAllPOSUnit.Get("NPR POS Unit No.") then
                                POSUnitsList.SetRecord(TempAllPOSUnit);

                        if POSUnitsList.RunModal() = Action::LookupOK then
                            "NPR POS Unit No." := TempAllPOSUnit."No.";

                        POSUnitsList.SetPOSUnitMode(false);
                    end;
                }
                field("Allow POS Unit Switch"; Rec."NPR Allow Register Switch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Allow POS Unit Switch field';
                }
                field("POS Unit Switch Filter"; Rec."NPR Register Switch Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR POS Unit Switch Filter field';
                }
                field(Email; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user''s email address.';
                }
                field("Anonymize Customers"; Rec."NPR Anonymize Customers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Anonymize Customers field';
                }
            }
        }
    }

    var
        TempAllSalesperson: Record "Salesperson/Purchaser" temporary;
        TempAllUser: Record User temporary;
        TempAllPOSUnit: Record "NPR POS Unit" temporary;
        UserId: Text;
        SalespersonCode: Code[20];

    procedure SetGlobals(var TempSalespersonAll: Record "NPR Salesperson Buffer"; var TempUserAll: Record User; var TempPOSUnit: Record "NPR POS Unit")
    begin
        TempAllSalesperson.DeleteAll();
        if TempSalespersonAll.FindSet() then
            repeat
                TempAllSalesperson.TransferFields(TempSalespersonAll);
                TempAllSalesperson.Insert();
            until TempSalespersonAll.Next() = 0;
        if TempAllSalesperson.FindSet() then;

        TempAllUser.DeleteAll();
        if TempUserAll.FindSet() then
            repeat
                TempAllUser := TempUserAll;
                TempAllUser.Insert();
            until TempUserAll.Next() = 0;
        if TempAllUser.FindSet() then;

        TempAllPOSUnit.DeleteAll();
        if TempPOSUnit.FindSet() then
            repeat
                TempAllPOSUnit := TempPOSUnit;
                TempAllPOSUnit."POS Store Code" := '';
                TempAllPOSUnit.Insert(false);
                TempAllPOSUnit."POS Store Code" := TempPOSUnit."POS Store Code";
                TempAllPOSUnit.Modify(false);
            until TempPOSUnit.Next() = 0;
        if TempAllPOSUnit.FindSet() then;
    end;

    procedure UserSetupsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CreateUserSetupData()
    var
        UserSetup: Record "User Setup";
    begin
        if Rec.FindSet() then
            repeat
                UserSetup := Rec;
                if not UserSetup.Insert() then
                    UserSetup.Modify();
            until Rec.Next() = 0;
    end;

    procedure CopyRealAndTempUsers(var TempUserAll: Record User)
    var
        User: Record User;
    begin
        TempUserAll.DeleteAll();

        if User.FindSet() then
            repeat
                TempUserAll := User;
                TempUserAll.Insert();
            until User.Next() = 0;
    end;
}