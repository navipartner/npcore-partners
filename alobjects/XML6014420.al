xmlport 6014420 "Retail Journal Import/Export"
{
    Caption = 'Retail Journal Import/Export';
    Format = VariableText;

    schema
    {
        textelement(RetailJournalFile)
        {
            tableelement("Retail Journal Line";"Retail Journal Line")
            {
                XmlName = 'ItemTable';
                fieldelement(ItemNo;"Retail Journal Line"."Item No.")
                {
                }
                fieldelement(Quantity;"Retail Journal Line"."Quantity to Print")
                {
                }
                fieldelement(Description;"Retail Journal Line".Description)
                {
                }
                fieldelement(VendorNo;"Retail Journal Line"."Vendor No.")
                {
                }
                fieldelement(VendorItemNo;"Retail Journal Line"."Vendor Item No.")
                {
                }
                fieldelement(UnitPrice;"Retail Journal Line"."Discount Price Incl. Vat")
                {
                }
                fieldelement(UnitCost;"Retail Journal Line"."Last Direct Cost")
                {
                }
                fieldelement(LineNo;"Retail Journal Line"."Line No.")
                {
                }
                fieldelement(SalesUnitOfMeassure;"Retail Journal Line"."Sales Unit of measure")
                {
                }
                fieldelement(Barcode;"Retail Journal Line".Barcode)
                {
                }
                fieldelement(MixedDiscount;"Retail Journal Line"."Mixed Discount")
                {
                }
                fieldelement(PeriodDiscount;"Retail Journal Line"."Period Discount")
                {
                }
                fieldelement(VariantCode;"Retail Journal Line"."Variant Code")
                {
                }
                fieldelement(Description2;"Retail Journal Line"."Description 2")
                {
                }
                fieldelement(ItemGroup;"Retail Journal Line"."Item group")
                {
                }
                fieldelement(Assortment;"Retail Journal Line".Assortment)
                {
                }
                fieldelement(NewItemNo;"Retail Journal Line"."New Item No.")
                {
                }
                fieldelement(NewItem;"Retail Journal Line"."New Item")
                {
                }
            }
        }
    }

    requestpage
    {
        Caption = 'Retail Journal Import/Export';

        layout
        {
        }

        actions
        {
        }
    }
}

