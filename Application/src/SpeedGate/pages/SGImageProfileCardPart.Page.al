page 6184927 "NPR SG ImageProfileCardPart"
{
    Extensible = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR SG ImageProfile";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Image Profiles Image Selection';
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Ready Image';
                field(ReadyImage; Rec.ReadyImage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ready Image field.', Comment = '%';
                }
            }
            group(Success)
            {
                Caption = 'Success Image';
                field(SuccessImage; Rec.SuccessImage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Success Image field.', Comment = '%';
                }
            }

            group("Error")
            {
                Caption = 'Error Image';
                field(ErrorImage; Rec.ErrorImage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Error Image field.', Comment = '%';
                }
            }

            group(TicketSuccess)
            {

                Caption = 'Ticket Success Image';
                field(TicketSuccessImage; Rec.TicketSuccessImage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ticket Success Image field.', Comment = '%';
                }
            }
            group(MemberCardSuccess)
            {
                Caption = 'Member Card Success Image';
                field(MemberCardSuccessImage; Rec.MemberCardSuccessImage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Card Success Image field.', Comment = '%';
                }

            }
            group(WalletSuccess)
            {
                Caption = 'Wallet Success Image';
                field(WalletSuccessImage; Rec.WalletSuccessImage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Wallet Success Image field.', Comment = '%';
                }

            }
            group(CityCardSuccess)
            {
                Caption = 'City Card Success Image';
                field(CityCardSuccessImage; Rec.CityCardSuccessImage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the City Card Success Image field.', Comment = '%';
                }

            }
            group(AnonymousMember)
            {
                Caption = 'Anonymous Member Avatar';
                field(AnonymousMemberAvatar; Rec.AnonymousMemberAvatar)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Anonymous Member Avatar field.', Comment = '%';
                }
            }

        }
    }

    actions
    {
        area(Processing)
        {
            Group(ImportImages)
            {
                Caption = 'Import Images';
                action(ImportReadyImage)
                {
                    Caption = 'Import Ready Image';
                    Image = Import;
                    ToolTip = 'Executes the Import Ready Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        SetRecImage(Rec.FieldNo(ReadyImage), Rec.FieldCaption(ReadyImage));
                    end;
                }

                action(ImportSuccessImage)
                {
                    Caption = 'Import Success Image';
                    Image = Import;
                    ToolTip = 'Executes the Import Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        SetRecImage(Rec.FieldNo(SuccessImage), Rec.FieldCaption(SuccessImage));
                    end;
                }

                action(ImportErrorImage)
                {
                    Caption = 'Import Error Image';
                    Image = Import;
                    ToolTip = 'Executes the Import Error Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        SetRecImage(Rec.FieldNo(ErrorImage), Rec.FieldCaption(ErrorImage));
                    end;
                }

                action(ImportTicketSuccessImage)
                {
                    Caption = 'Import Ticket Success Image';
                    Image = Import;
                    ToolTip = 'Executes the Import Ticket Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        SetRecImage(Rec.FieldNo(TicketSuccessImage), Rec.FieldCaption(TicketSuccessImage));
                    end;
                }

                action(ImportMemberCardSuccessImage)
                {
                    Caption = 'Import Member Card Success Image';
                    Image = Import;
                    ToolTip = 'Executes the Import Member Card Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        SetRecImage(Rec.FieldNo(MemberCardSuccessImage), Rec.FieldCaption(MemberCardSuccessImage));
                    end;
                }

                action(ImportWalletSuccessImage)
                {
                    Caption = 'Import Wallet Success Image';
                    Image = Import;
                    ToolTip = 'Executes the Import Wallet Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        SetRecImage(Rec.FieldNo(WalletSuccessImage), Rec.FieldCaption(WalletSuccessImage));
                    end;
                }

                action(ImportCityCardSuccessImage)
                {
                    Caption = 'Import City Card Success Image';
                    Image = Import;
                    ToolTip = 'Executes the Import City Card Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        SetRecImage(Rec.FieldNo(CityCardSuccessImage), Rec.FieldCaption(CityCardSuccessImage));
                    end;
                }

                action(ImportAnonymousMemberAvatar)
                {
                    Caption = 'Import Anonymous Member Avatar';
                    Image = Import;
                    ToolTip = 'Executes the Import Anonymous Member Avatar action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        SetRecImage(Rec.FieldNo(AnonymousMemberAvatar), Rec.FieldCaption(AnonymousMemberAvatar));
                    end;
                }
            }

            Group(DeleteImages)
            {
                Caption = 'Delete Images';
                action(DeleteReadyImage)
                {
                    Caption = 'Delete Ready Image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete Ready Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ClearRecImage(Rec.FieldNo(ReadyImage), Rec.FieldCaption(ReadyImage));
                    end;
                }

                action(DeleteSuccessImage)
                {
                    Caption = 'Delete Success Image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ClearRecImage(Rec.FieldNo(SuccessImage), Rec.FieldCaption(SuccessImage));
                    end;
                }

                action(DeleteErrorImage)
                {
                    Caption = 'Delete Error Image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete Error Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ClearRecImage(Rec.FieldNo(ErrorImage), Rec.FieldCaption(ErrorImage));
                    end;
                }

                action(DeleteTicketSuccessImage)
                {
                    Caption = 'Delete Ticket Success Image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete Ticket Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ClearRecImage(Rec.FieldNo(TicketSuccessImage), Rec.FieldCaption(TicketSuccessImage));
                    end;
                }

                action(DeleteMemberCardSuccessImage)
                {
                    Caption = 'Delete Member Card Success Image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete Member Card Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ClearRecImage(Rec.FieldNo(MemberCardSuccessImage), Rec.FieldCaption(MemberCardSuccessImage));
                    end;
                }

                action(DeleteWalletSuccessImage)
                {
                    Caption = 'Delete Wallet Success Image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete Wallet Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ClearRecImage(Rec.FieldNo(WalletSuccessImage), Rec.FieldCaption(WalletSuccessImage));
                    end;
                }

                action(DeleteCityCardSuccessImage)
                {
                    Caption = 'Delete City Card Success Image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete City Card Success Image action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ClearRecImage(Rec.FieldNo(CityCardSuccessImage), Rec.FieldCaption(CityCardSuccessImage));
                    end;
                }

                action(DeleteAnonymousMemberAvatar)
                {
                    Caption = 'Delete Anonymous Member Avatar';
                    Image = Delete;
                    ToolTip = 'Executes the Delete Anonymous Member Avatar action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ClearRecImage(Rec.FieldNo(AnonymousMemberAvatar), Rec.FieldCaption(AnonymousMemberAvatar));
                    end;
                }
            }
        }

    }

    local procedure SetRecImage(FieldNumber: Integer; FieldCaption: Text)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: Instream;
        RecRef: RecordRef;
    begin
        FileManagement.BLOBImport(TempBlob, '');
        if (not TempBlob.Hasvalue()) then
            Error('');
        TempBlob.CreateInStream(InStr);

        Clear(Rec.TemporaryImageBuffer);
        Rec.TemporaryImageBuffer.ImportStream(InStr, FieldCaption);

        RecRef.Open(Database::"NPR SG ImageProfile");
        RecRef.GetBySystemId(Rec.SystemId);
        RecRef.Field(FieldNumber).Value := Rec.TemporaryImageBuffer;
        RecRef.Modify();
        CurrPage.Update(false);
    end;

    local procedure ClearRecImage(FieldNumber: Integer; FieldCaption: Text)
    var
        RecRef: RecordRef;
        NullGuid: Guid;
        ConfirmDelete: Label 'Are you sure you want to delete the %1 image?';
    begin
        if (not Confirm(ConfirmDelete, true, FieldCaption)) then
            exit;

        RecRef.Open(Database::"NPR SG ImageProfile");
        RecRef.GetBySystemId(Rec.SystemId);
        RecRef.Field(FieldNumber).Value := NullGuid;
        RecRef.Modify();
        CurrPage.Update(false);
    end;

}