#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6150950 "NPR Ecom Related Documents"
{
    Extensible = false;
    Caption = 'Related Documents';
    PageType = List;
    SourceTable = "NPR Ecom Related Document";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the type of the related document.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the document number.';

                    trigger OnDrillDown()
                    begin
                        _EcomRelatedDocMgt.OpenRelatedDocument(Rec);
                    end;
                }
            }
        }
    }

    var
        _EcomRelatedDocMgt: Codeunit "NPR Ecom Related Doc Mgt";
}
#endif
