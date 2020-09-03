table 6059937 "NPR RSS Feed Channel Sub."
{
    // NPR5.22/TJ/20160407 CASE 233762 Added new fields Url, Show As New Within and Default

    Caption = 'RSS Feed Channel Subscription';
    DrillDownPageID = "NPR RSS Feed Channel Sub.";
    LookupPageID = "NPR RSS Feed Channel Sub.";

    fields
    {
        field(1; "Feed Code"; Code[10])
        {
            Caption = 'Feed Code';
        }
        field(10; Url; Text[250])
        {
            Caption = 'Url';
            Description = 'NPR5.22';
        }
        field(20; "Show as New Within"; DateFormula)
        {
            Caption = 'Show as New Within';
            Description = 'NPR5.22';
        }
        field(30; Default; Boolean)
        {
            Caption = 'Default';
            Description = 'NPR5.22';

            trigger OnValidate()
            begin
                if Default and (Default <> xRec.Default) then begin
                    RssFeedChSub.SetFilter("Feed Code", '<>%1', "Feed Code");
                    RssFeedChSub.SetRange(Default, Default);
                    if RssFeedChSub.FindFirst then
                        if not Confirm(DefaultSubFound) then
                            Default := xRec.Default
                        else begin
                            RssFeedChSub.Default := xRec.Default;
                            RssFeedChSub.Modify;
                        end;
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Feed Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RssFeedChSub: Record "NPR RSS Feed Channel Sub.";
        DefaultSubFound: Label 'There is allready a default feed subscription set. Do you want to make this one as new default?';
}

