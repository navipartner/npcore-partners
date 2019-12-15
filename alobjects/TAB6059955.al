table 6059955 "MCS API Setup"
{
    // NPR5.29/CLVA/20170125 CASE 264333 Added fields "Image Orientation" and "Use Cognitive Services"
    // 252646 /CLVA/20170220 CASE 252646 Added option value "Recommendation" to field API
    // NPR5.30/NPKNAV/20170310  CASE 252646 Transport NPR5.30 - 26 January 2017

    Caption = 'MCS API Setup';

    fields
    {
        field(1;API;Option)
        {
            Caption = 'API';
            OptionCaption = 'Face,Speech,Recommendation';
            OptionMembers = Face,Speech,Recommendation;
        }
        field(11;"Key 1";Text[50])
        {
            Caption = 'Key 1';
        }
        field(12;"Key 2";Text[50])
        {
            Caption = 'Key 2';
        }
        field(13;"Image Orientation";Option)
        {
            Caption = 'Image Orientation';
            OptionCaption = 'Landscape,Portrait';
            OptionMembers = Landscape,Portrait;
        }
        field(14;"Use Cognitive Services";Boolean)
        {
            Caption = 'Use Cognitive Services';
        }
    }

    keys
    {
        key(Key1;API)
        {
        }
    }

    fieldgroups
    {
    }
}

