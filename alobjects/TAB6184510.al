table 6184510 "EFT BIN Range"
{
    // NPR5.40/NPKNAV/20180330  CASE 290734 Transport NPR5.40 - 30 March 2018
    // NPR5.53/MMV /20191204 CASE 349520 Added conditional validation

    Caption = 'EFT BIN Range';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "BIN from"; BigInteger)
        {
            Caption = 'BIN from';
            DataClassification = CustomerContent;
        }
        field(2; "BIN to"; BigInteger)
        {
            Caption = 'BIN to';
            DataClassification = CustomerContent;
        }
        field(3; "BIN Group Code"; Code[10])
        {
            Caption = 'BIN Group Code';
            DataClassification = CustomerContent;
            TableRelation = "EFT BIN Group".Code;

            trigger OnValidate()
            var
                EFTBINGroup: Record "EFT BIN Group";
            begin
                //-NPR5.53 [349520]
                if EFTBINGroup.Get("BIN Group Code") then
                    //+NPR5.53 [349520]
                    "BIN Group Priority" := EFTBINGroup.Priority;
            end;
        }
        field(4; "BIN Group Priority"; Integer)
        {
            Caption = 'BIN Group Priority';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "BIN from", "BIN to", "BIN Group Code")
        {
        }
        key(Key2; "BIN Group Priority")
        {
        }
    }

    fieldgroups
    {
    }

    procedure FindMatch(BIN: Text): Boolean
    var
        BigInt: BigInteger;
    begin
        if not TryParseBIN(BIN, BigInt) then
            exit(false);

        SetCurrentKey("BIN Group Priority");
        SetFilter("BIN from", '<=%1', BigInt);
        SetFilter("BIN to", '>=%1', BigInt);
        exit(FindFirst);
    end;

    [TryFunction]
    local procedure TryParseBIN(BINText: Text; var BINOut: BigInteger)
    var
        Regex: DotNet npNetRegex;
        Match: DotNet npNetMatch;
    begin
        Regex := Regex.Regex('^\d*');
        Match := Regex.Match(BINText);
        if not Match.Success then
            Error('');
        Evaluate(BINOut, Match.Value);
    end;
}

