import QtQuick 2.4
import QtQuick.Controls 2.1

import "../../scripts/Constants.js" as Constants

PageDefinitionsSCAPForm {

    Connections {
        target: gapi
        onSignalGenericError: {
            propertyBusyIndicator.running = false
        }
        onSignalEntityAttributesLoadedError: {
            console.log("Definitions SCAP - Signal SCAP entities loaded error")
            mainFormID.propertyPageLoader.propertyGeneralTitleText.text =
                    qsTranslate("PageDifinitionsSCAP","STR_SCAP_ERROR")
            mainFormID.propertyPageLoader.propertyGeneralPopUpLabelText.text =
                    qsTranslate("PageDifinitionsSCAP","STR_SCAP_LOAD_ENTITIES_ERROR")
            mainFormID.propertyPageLoader.propertyGeneralPopUp.visible = true
            if(propertyBar.currentIndex == 0)
                propertyBusyIndicatorAttributes.running = false
        }
        onSignalCompanyAttributesLoadedError: {
            console.log("Definitions SCAP - Signal SCAP company loaded error")
            mainFormID.propertyPageLoader.propertyGeneralTitleText.text =
                    qsTranslate("PageDifinitionsSCAP","STR_SCAP_ERROR")
            mainFormID.propertyPageLoader.propertyGeneralPopUpLabelText.text =
                    qsTranslate("PageDifinitionsSCAP","STR_SCAP_LOAD_COMPANY_ERROR")
            mainFormID.propertyPageLoader.propertyGeneralPopUp.visible = true
            if(propertyBar.currentIndex == 1)
                propertyBusyIndicatorAttributes.running = false
        }
        onSignalSCAPEntitiesLoaded: {
            console.log("Definitions SCAP - Signal SCAP entities loaded")
            for (var i = 0; i < entitiesList.length; i++)
            {
                entityAttributesModel.append({
                                                 entityName: entitiesList[i], attribute: "", checkBoxAttr: false
                                             });
            }

            // Load attributes from cache (Entities, isShortDescription)
            gapi.startLoadingAttributesFromCache(0, 0)
            // Load attributes from cache (Companies, isShortDescription)
            gapi.startLoadingAttributesFromCache(1, 0)
            propertyBusyIndicator.running = false

        }
        onSignalEntityAttributesLoaded:{
            console.log("Definitions SCAP - Signal SCAP Entity attributes loaded")
            if(entityAttributesModel.count == 0){
                for(var i = 0; i < attribute_list.length; i=i+2)
                {
                    entityAttributesModel.append({
                                                     entityName: attribute_list[i], attribute: "<ul><li>"+attribute_list[i+1]+"</li></ul>"
                                                 });
                }
            }else{
                // Remove old attributes
                for(i = 0; i < attribute_list.length; i=i+2)
                {
                    for (var j = 0; j < entityAttributesModel.count; j++){
                        if(entityAttributesModel.get(j).entityName === attribute_list[i]){
                            entityAttributesModel.set(j, {"entityName": attribute_list[i], "attribute":""})
                        }
                    }
                }
                // Add new attribute
                for(i = 0; i < attribute_list.length; i=i+2)
                {
                    for (var j = 0; j < entityAttributesModel.count; j++){
                        if(entityAttributesModel.get(j).entityName === attribute_list[i]){
                            entityAttributesModel.set(j, {"entityName": attribute_list[i], "attribute":
                                                          entityAttributesModel.get(j).attribute
                                                          + "<ul><li>"+attribute_list[i+1]+"</li></ul>"})
                        }
                    }
                }
            }
            propertyBusyIndicatorAttributes.running = false
        }
        onSignalCompanyAttributesLoaded: {
            console.log("Definitions SCAP - Signal SCAP company attributes loaded")
            for(var i = 0; i < attribute_list.length; i=i+2)
            {
                if(companyAttributesModel.count>0 &&
                        companyAttributesModel.get(companyAttributesModel.count-1).entityName === attribute_list[i]){
                    companyAttributesModel.set(companyAttributesModel.count-1,{
                                                   entityName: attribute_list[i],
                                                   attribute: companyAttributesModel.get
                                                              (companyAttributesModel.count-1).attribute
                                                              + "<ul><li>"+attribute_list[i+1]+"</li></ul>"
                                               });
                }else{
                    companyAttributesModel.append({
                                                      entityName: attribute_list[i], attribute: "<ul><li>"+attribute_list[i+1]+"</li></ul>"
                                                  });
                }
            }
            propertyBusyIndicatorAttributes.running = false
        }
    }

    Component {
        id: attributeListDelegate
        Rectangle {
            width: parent.width - propertyEntitiesListViewScroll.width
                   - Constants.SIZE_ROW_H_SPACE * 0.5
            height: columnItem.height + 10
            id: container
            color: Constants.COLOR_MAIN_SOFT_GRAY
            CheckBox {
                id: checkboxSel
                height: 25
                width: 50
                font.family: lato.name
                font.pixelSize: Constants.SIZE_TEXT_FIELD
                font.capitalization: Font.MixedCase
                anchors.top: parent.top
                onCheckedChanged: {

                    entityAttributesModel.get(index).checkBoxAttr = checkboxSel.checked

                    propertyButtonLoadEntityAttributes.enabled = false
                    for (var i = 0; i < entityAttributesModel.count; i++){
                        if(entityAttributesModel.get(i).checkBoxAttr === true){
                            propertyButtonLoadEntityAttributes.enabled = true
                            break
                        }
                    }

                }
            }
            Column {
                id: columnItem
                anchors.left: checkboxSel.right
                width: parent.width - checkboxSel.width - Constants.SIZE_ROW_H_SPACE * 0.5
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: '<b>Entidade:</b> ' + entityName
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    text: "<b>Atributos:</b>"
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: attribute
                }
            }

        }
    }
    Component {
        id: attributeListDelegateCompanies
        Rectangle {
            width: parent.width - propertyCompaniesListViewScroll.width
                   - Constants.SIZE_ROW_H_SPACE * 0.5
            height: columnItem.height + 10
            id: container
            color: Constants.COLOR_MAIN_SOFT_GRAY
            Column {
                id: columnItem
                width: parent.width - Constants.SIZE_ROW_H_SPACE
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: '<b>Entidade:</b> ' + entityName
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    text: "<b>Atributos:</b>"
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: attribute
                }
            }

        }
    }

    ListModel {
        id: companyAttributesModel
    }

    ListModel {
        id: entityAttributesModel
    }

    propertyButtonLoadCompanyAttributes {
        onClicked: {
            console.log("ButtonLoadCompanyAttributes clicked!")
            companyAttributesModel.clear()
            propertyBusyIndicatorAttributes.running = true
            gapi.startGettingCompanyAttributes()
        }

    }

    propertyButtonLoadEntityAttributes {
        onClicked: {
            console.log("ButtonLoadEntityAttributes clicked!")
            propertyBusyIndicatorAttributes.running = true
            var attributeList = []
            var count = 0
            for (var i = 0; i < entityAttributesModel.count; i++){
                if(entityAttributesModel.get(i).checkBoxAttr == true){
                    attributeList[count] = i
                    count++
                }
            }
            console.log("QML AttributeList: ", attributeList)
            gapi.startGettingEntityAttributes(attributeList)
        }
    }

    Component.onCompleted: {
        console.log("Page Definitions SCAP Completed")
        propertyBusyIndicator.running = true
        propertyBusyIndicatorAttributes.running = true
        gapi.startGettingEntities()
    }
}
