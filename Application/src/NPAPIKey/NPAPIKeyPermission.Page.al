#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185108 "NPR NP API Key Permission"
{
    PageType = ListPart;
    SourceTable = "NPR NP API Key Permission";
    Extensible = false;
    Editable = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(NPAPIKeyPermissionRepeater)
            {
                field("Permission Set ID"; Rec."Permission Set ID")
                {
                    ApplicationArea = NPRRetail;
                }
                field("Permission Set Name"; Rec."Permission Set Name")
                {
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
#endif