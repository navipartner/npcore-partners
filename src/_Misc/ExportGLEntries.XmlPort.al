xmlport 6014403 "NPR Export G/L Entries"
{
    // NPR4.16/JDH/20151115 CASE 226013 first version created

    Caption = 'Export G/L Entries';
    Direction = Export;
    Format = VariableText;

    schema
    {
        textelement(Root)
        {
            tableelement("G/L Entry"; "G/L Entry")
            {
                RequestFilterFields = "G/L Account No.", "Posting Date";
                XmlName = 'GLEntry';
                fieldelement(AccNo; "G/L Entry"."G/L Account No.")
                {
                }
                fieldelement(PostingDate; "G/L Entry"."Posting Date")
                {
                }
                fieldelement(DocNo; "G/L Entry"."Document No.")
                {
                }
                fieldelement(Desc; "G/L Entry".Description)
                {
                }
                fieldelement(Quantity; "G/L Entry".Quantity)
                {
                }
                fieldelement(Amount; "G/L Entry".Amount)
                {
                }
                fieldelement(GD1; "G/L Entry"."Global Dimension 1 Code")
                {
                }
                fieldelement(GD2; "G/L Entry"."Global Dimension 2 Code")
                {
                }
                fieldelement(VATAmount; "G/L Entry"."VAT Amount")
                {
                }
                fieldelement(SourceType; "G/L Entry"."Source Type")
                {
                }
                fieldelement(SourceNo; "G/L Entry"."Source No.")
                {
                }
                fieldelement(VATProdPostGrp; "G/L Entry"."VAT Prod. Posting Group")
                {
                }
                fieldelement(GenPostType; "G/L Entry"."Gen. Posting Type")
                {
                }
            }
        }
    }

    requestpage
    {
        Caption = 'Export G/L Entries';

        layout
        {
        }

        actions
        {
        }
    }
}

