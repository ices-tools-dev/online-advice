options(icesSAG.use_token = TRUE)

access_sag_data <- function(stock_code, year) {

    # Dowload the data
    SAGsummary <- getSAG(stock_code, year,
        data = "summary", combine = TRUE, purpose = "Advice"
    )
    SAGrefpts <- getSAG(stock_code, year,
        data = "refpts", combine = TRUE, purpose = "Advice"
    )

    data_sag <- cbind(SAGsummary, SAGrefpts)
    data_sag <- subset(data_sag, select = -fishstock)
    #print(data_sag %>% tibble())
}

# stock_list_all <- jsonlite::fromJSON(
#             URLencode(
#                 #"http://sd.ices.dk/services/odata4/StockListDWs4?$filter=ActiveYear eq 2020&$select=AssessmentKey,DataCategory,StockKey, StockKeyLabel, EcoRegion, SpeciesScientificName,  SpeciesCommonName, ExpertGroup"
#                 "http://sd.ices.dk/services/odata4/StockListDWs4?$filter=ActiveYear eq 2021"
#                 #"http://sd.ices.dk/services/odata4/StockListDWs4?$filter=ActiveYear eq 2021&$DataCategory eq 1"
#             )
#         )$value
# stock_list_cat1 <- stock_list_all  %>% filter(DataCategory == "1")
# stock_list_all  %>% tibble()


# function to dowload the quality assessemnt data
quality_assessment_data <- function(stock_code){

years <- c(2021, 2020, 2019, 2018, 2017)
datalist = list()

for (i in years) {
    print(i)
    data_temp <- try(access_sag_data(stock_code, i)) # "had.27.6b"

    ###############
    if (isTRUE(class(data_temp) == "try-error")) {
        next
    }
    else {
        #
        data_temp <- filter(data_temp, between(Year, 2005, 2021))
        data_temp <- data_temp %>% select(Year, recruitment, SSB, F, Bpa, Blim, MSYBtrigger, FLim, Fpa, FMSY, RecruitmentAge, AssessmentYear, StockPublishNote,Purpose)
        datalist[[i]] <- data_temp
        # }
    }
}


### bind data in unique df
big_data <- dplyr::bind_rows(datalist)

# find last asseement year
last_year <- tail(big_data$AssessmentYear, n=1)

# subset last year
big_data_last_year <- big_data  %>% filter(AssessmentYear == last_year)

# take out non published data from before 2021 in big data
big_data <- filter(big_data, StockPublishNote == "Stock published")
big_data <- filter(big_data, Purpose == "Advice")
# put together the published data from before 2021 with the unpublished from 2021
big_data <- rbind(big_data, big_data_last_year)

#make assessmentYear as factor
big_data$AssessmentYear <- as.factor(big_data$AssessmentYear)
big_data_last_year$AssessmentYear <- as.factor(big_data_last_year$AssessmentYear)

df_list <- list(big_data, big_data_last_year)
return(df_list)
}

# list_df <- quality_assessment_data("hom.27.2a4a5b6a7a-ce-k8")
# list_df

# # # list_df_copy <-  filter(list_df[[1]], StockPublishNote == "Stock published")
# df <-access_sag_data("hom.27.2a4a5b6a7a-ce-k8", 2020)
# df


# stock_list_all <- jsonlite::fromJSON(
#             URLencode(
#                 "http://sd.ices.dk/services/odata4/StockListDWs4?$filter=ActiveYear eq 2021&$select=StockKey, StockKeyLabel, EcoRegion, SpeciesScientificName,  SpeciesCommonName, DataCategory"
#             )
#         )$value

# stock_list_all  %>% tibble()
# freq_Eco_region <- data.frame(table(stock_list_all$EcoRegion))

# stock_list_all <- jsonlite::fromJSON(
#             URLencode(
#                 "http://sd.ices.dk/services/odata4/StockListDWs4?$filter=ActiveYear eq 2020"
#             )
#         )$value