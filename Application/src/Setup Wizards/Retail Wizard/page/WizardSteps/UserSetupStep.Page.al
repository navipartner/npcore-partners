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

                    Caption = 'User Id';
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';

                    Lookup = true;
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the earliest date on which the user is allowed to post to the company.';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Posting To"; Rec."Allow Posting To")
                {

                    ToolTip = 'Specifies the last date on which the user is allowed to post to the company.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit Time"; Rec."Register Time")
                {

                    ToolTip = 'Specifies whether to register the user''s time usage defined as the time spent from when the user logs in to when the user logs out. Unexpected interruptions, such as idle session timeout, terminal server idle session timeout, or a client crash are not recorded.';
                    ApplicationArea = NPRRetail;
                }
                field("Salespers./Purch. Code"; SalespersonCode)
                {

                    Caption = 'Salesperson Code';
                    ToolTip = 'Specifies the code for the salesperson or purchaser for the user.';

                    Lookup = true;
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the code for the responsibility center to which you want to assign the user.';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the code for the responsibility center to which you want to assign the user.';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the code for the responsibility center you want to assign to the user. The user will only be able to see service documents for the responsibility center specified in the field. This responsibility center will also be the default responsibility center when the user creates new service documents.';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies if a user is a time sheet administrator. A time sheet administrator can access any time sheet and then edit, change, or delete it.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR POS Unit No."; Rec."NPR POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the NPR Backoffice POS Unit No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSUnitsList: Page "NPR POS Units Select";
                    begin
                        POSUnitsList.LookupMode := true;

                        POSUnitsList.SetPOSUnitMode(true);
                        POSUnitsList.SetRec(TempAllPOSUnit);

                        if Rec."NPR POS Unit No." <> '' then
                            if TempAllPOSUnit.Get(Rec."NPR POS Unit No.") then
                                POSUnitsList.SetRecord(TempAllPOSUnit);

                        if POSUnitsList.RunModal() = Action::LookupOK then
                            Rec."NPR POS Unit No." := TempAllPOSUnit."No.";

                        POSUnitsList.SetPOSUnitMode(false);
                    end;
                }
                field("Allow POS Unit Switch"; Rec."NPR Allow Register Switch")
                {

                    ToolTip = 'Specifies the value of the NPR Allow POS Unit Switch field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit Switch Filter"; Rec."NPR Register Switch Filter")
                {

                    ToolTip = 'Specifies the value of the NPR POS Unit Switch Filter field';
                    ApplicationArea = NPRRetail;
                }
                field(Email; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the user''s email address.';
                    ApplicationArea = NPRRetail;
                }
                field("Anonymize Customers"; Rec."NPR Anonymize Customers")
                {

                    ToolTip = 'Specifies the value of the NPR Anonymize Customers field';
                    ApplicationArea = NPRRetail;
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