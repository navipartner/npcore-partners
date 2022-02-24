page 6059851 "NPR POS Item Avail. Check"
{
    Extensible = false;
    Caption = 'Availability Check';
    SourceTable = "NPR POS Sale";
    Editable = false;
    LinksAllowed = false;
    UsageCategory = None;
    PageType = ListPlus;

    layout
    {
        area(content)
        {
            label(HeadingLbl)
            {
                ApplicationArea = NPRRetail;
                CaptionClass = Heading;
                ShowCaption = false;
            }
            part(AvailabilityCheckDetails; "NPR POS Item Avail. Check Det.")
            {
                ApplicationArea = NPRRetail;
                Editable = false;
            }
        }
    }

    procedure SetHeading(Value: Text)
    begin
        Heading := Value;
    end;

    procedure SetAvailabilityCheckDetails(var PosItemAvailability: Record "NPR POS Item Availability"; ShowCurrentLineQty: Boolean)
    begin
        CurrPage.AvailabilityCheckDetails.Page.SetDataset(PosItemAvailability);
        CurrPage.AvailabilityCheckDetails.Page.SetShowCurrentLineQtyColumn(ShowCurrentLineQty);
    end;

    var
        Heading: Text;
}