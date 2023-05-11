table 6059865 "NPR NPCamera Profile"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;
    fields
    {
        field(1; Code; Code[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; "File Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "PNG","JPEG";
        }
        field(3; "Quality Option"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Very Low","Low","Medium","High","Very High","Custom";

            trigger OnValidate()
            begin
                case rec."Quality Option" of
                    "Quality Option"::"Very Low":
                        rec."Quality Value" := 0.2;
                    "Quality Option"::"Low":
                        rec."Quality Value" := 0.4;
                    "Quality Option"::"Medium":
                        rec."Quality Value" := 0.6;
                    "Quality Option"::"High":
                        rec."Quality Value" := 0.8;
                    "Quality Option"::"Very High":
                        rec."Quality Value" := 1;
                end;
            end;

        }
        field(4; "Quality Value"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0.0;
            MaxValue = 1.0;
        }
        field(5; "Pixel X"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Pixel Y"; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
}