page 6150858 "NPR NPCamera Profile List"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR NPCamera Profile";
    Extensible = false;
    Caption = 'Np Camera Profiles';
#if NOT BC17
    AboutTitle = 'Camera Profile';
    AboutText = 'A list of camera profiles which can be used in different contexts. Depending on the need for the specific usecsae.';
#endif

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a unique code identifying a specific profile. Add code DEFAULT to be used everywhere except where other profiles are specified.';
                }
                field("File type"; Rec."File Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the wanted file type encoding used.';
                }
                field("Quality Option"; Rec."Quality Option")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a set of options for quality of the image taken by the camera.';
                }
                field("Quality Value"; Rec."Quality Value")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the quality, ranges from 0.0 to 1.0, where 0.0 is the lowest. The lower the quality the lower the image size.';
                }
                field("Pixel X"; Rec."Pixel X")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the width of the cameras picture in pixels. It will select the closest possible value of this.';
                }
                field("Pixel Y"; Rec."Pixel Y")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the width of the cameras picture in pixels. It will select the closest possible value of this.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Test Selected")
            {
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Camera;
                ToolTip = 'Test te Camera with the selected profile.';
                trigger OnAction();
                var
                    Camera: Page "NPR NPCamera";
                    inS: InStream;
                    toFile: Text;
                begin
                    toFile := Rec.Code + '.' + Format(Rec."File Type");
                    if (Camera.TakePicture(inS, Rec)) then
                        File.DownloadFromStream(inS, '', '', '', toFile);
                end;
            }
            action("Test Default")
            {
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Camera;
                ToolTip = 'Test the camera with default profile.';
                trigger OnAction();
                var
                    Camera: Page "NPR NPCamera";
                    NPCameraProfile: Record "NPR NPCamera Profile";
                    inS: InStream;
                    toFile: Text;
                begin
                    if (NPCameraProfile.Get('DEFAULT')) then
                        toFile := NPCameraProfile.Code + '.' + Format(NPCameraProfile."File Type")
                    else
                        toFile := 'default.jpeg';
                    if (Camera.TakePicture(inS)) then
                        File.DownloadFromStream(inS, '', '', '', toFile);
                end;
            }
        }
    }
}