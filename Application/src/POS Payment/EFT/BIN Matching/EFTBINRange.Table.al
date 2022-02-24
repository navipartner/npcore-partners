table 6184510 "NPR EFT BIN Range"
{
    Access = Internal;
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
            TableRelation = "NPR EFT BIN Group".Code;

            trigger OnValidate()
            var
                EFTBINGroup: Record "NPR EFT BIN Group";
            begin
                if EFTBINGroup.Get("BIN Group Code") then
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

    procedure FindMatch(BIN: Text): Boolean
    var
        BigInt: BigInteger;
    begin
        if not TryParseBIN(BIN, BigInt) then
            exit(false);

        SetCurrentKey("BIN Group Priority");
        SetFilter("BIN from", '<=%1', BigInt);
        SetFilter("BIN to", '>=%1', BigInt);
        exit(FindFirst());
    end;

    [TryFunction]
    local procedure TryParseBIN(BINText: Text; var BINOut: BigInteger)
    var
        NpRegEx: Codeunit "NPR RegEx";
        MatchValue: Text;
    begin
        if not NpRegEx.GetSingleMatchValue(BINText, '^\d*', MatchValue) then
            Error('');
        Evaluate(BINOut, MatchValue);
    end;
}

