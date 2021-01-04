pageextension 6014452 "NPR Contact Card" extends "Contact Card"
{
    layout
    {
        addafter(Name)
        {
            field("NPR Name 2"; "Name 2")
            {
                ApplicationArea = All;
                Importance = Additional;
                ToolTip = 'Specifies the value of the Name 2 field';
            }
        }
        addafter("Foreign Trade")
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                field("NPR Magento Contact"; "NPR Magento Contact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Contact field';
                }
                field("NPR Magento Customer Group"; "NPR Magento Customer Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Customer Group field';
                }
                field("NPR Magento Payment Methods"; "NPR Magento Payment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Payment Methods field';
                }
                field("NPR Magento Shipment Methods"; "NPR Magento Shipment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Shipment Methods field';
                }
                field("NPR Magento Account Status"; "NPR Magento Account Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Account Status field';
                }
                field("NPR Magento Price Visibility"; "NPR Magento Price Visibility")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Price Visibility field';
                }
            }
        }
        addfirst(FactBoxes)
        {
            part("NPR PersonStatistics"; "NPR Person Statistics")
            {
                Caption = 'Facial Recognition';
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter(Statistics)
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entries action';
            }
        }
        addafter("Create &Interaction")
        {
            group("NPR SMS")
            {
                Caption = 'SMS';
                action("NPR SendSMS")
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send SMS action';
                }
            }
            group("NPR ResetPassword")
            {
                Caption = 'Magento';
                action("NPR ResetMagentoPassword")
                {
                    Caption = 'Reset Magento Password';
                    Image = UserCertificate;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Reset Magento Password action';
                }
            }
        }
        addfirst(Processing)
        {
            group("NPR FacialRecognition")
            {
                Caption = 'Facial Recognition';
                Image = PersonInCharge;
                action("NPR ImportFace")
                {
                    Caption = 'Import Face Image';
                    ApplicationArea = All;
                    Image = Picture;
                    ToolTip = 'Executes the Import Face Image action';

                    trigger OnAction()
                    var
                        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
                        FacialRecognitionDetect: Codeunit "NPR Detect Face";
                        FacialRecognitionPersonGroup: Codeunit "NPR Create Person Group";
                        FacialRecognitionPerson: Codeunit "NPR Create Person";
                        FacialRecognitionPersonFace: Codeunit "NPR Add Person Face";
                        FacialRecognitionTrainPersonGroup: Codeunit "NPR Train Person Group";
                        ImageMgt: Codeunit "NPR Image Mgt.";
                        ImageFilePath: Text;
                        EntryNo: Integer;
                        CalledFrom: Option Contact,Member;
                        NotSetUp: Label 'Facial Recognition is not active. \It can be enabled from the Facial Recognition setup.';
                        ImgCantBeProcessed: Label 'Media not supported \ \Image can''t be processed. \Please use .jpg or .png images .';
                        ConnectionError: Label 'The API can''t be reached. \Please contact your administrator.';
                        NoNameError: Label 'Contact information is not complete. \Action aborted.';
                    begin
                        if not FacialRecognitionSetup.FindFirst() or not FacialRecognitionSetup.Active then begin
                            Message(NotSetUp);
                            exit;
                        end;

                        if not FacialRecognitionPersonGroup.GetPersonGroups() then begin
                            Message(ConnectionError);
                            exit;
                        end;

                        if Rec."Name" = '' then begin
                            Message(NoNameError);
                            exit;
                        end;

                        FacialRecognitionPersonGroup.CreatePersonGroup(Rec, false);

                        FacialRecognitionPerson.CreatePerson(Rec, false);

                        FacialRecognitionDetect.DetectFace(Rec, ImageFilePath, EntryNo, false, CalledFrom::Contact);
                        case ImageFilePath of
                            '':
                                exit;
                            'WrongExtension':
                                begin
                                    Message(ImgCantBeProcessed);
                                    exit;
                                end;
                        end;

                        if FacialRecognitionPersonFace.AddPersonFace(Rec, ImageFilePath, EntryNo) then begin
                            FacialRecognitionTrainPersonGroup.TrainPersonGroup(Rec, false);
                            ImageMgt.UpdateRecordImage("No.", CalledFrom::Contact, ImageFilePath);
                        end else
                            Message(ImgCantBeProcessed);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        FacialRecognition: Record "NPR Facial Recognition";
    begin
        FacialRecognition.SetRange("Contact No.", "No.");
        if FacialRecognition.FindLast() then
            CurrPage."NPR PersonStatistics".Page.SetValues(FacialRecognition.Age, FacialRecognition.Gender)
        else
            CurrPage."NPR PersonStatistics".Page.ResetValues();
    end;
}

