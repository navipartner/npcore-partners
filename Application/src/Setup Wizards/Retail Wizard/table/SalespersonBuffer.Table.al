table 6014456 "NPR Salesperson Buffer"
{
    Access = Internal;
    Caption = 'Salesperson Buffer';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(6014456; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; code)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        WantedStartingNo: Code[10];
        TempAllSalesperson: Record "NPR Salesperson Buffer" temporary;
        SalespersonBuffer: Record "NPR Salesperson Buffer";
        SalespersonPurchaserWP: page "NPR Salesperson/Purchaser Step";
    begin
        "Entry No." := 1;
        if SalespersonBuffer.FindLast() then
            "Entry No." := SalespersonBuffer."Entry No." + 1;

        WantedStartingNo := Code;

        SalespersonPurchaserWP.CopyRealAndTemp(TempAllSalesperson);
        SalespersonPurchaserWP.CheckIfNoAvailableInSalespersonPurchaser(TempAllSalesperson, WantedStartingNo);

        Code := WantedStartingNo;
    end;
}
