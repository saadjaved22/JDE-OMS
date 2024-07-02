public class NewsLetterService {
    
    public class NewsLetterWrapper{
        public Boolean userNameMissing;
        public Boolean newsletterIdMissing;
        public Boolean statusMissing;
        public Boolean extendedStatusMissing;
        public Boolean campaignName;
        
        public NewsLetterWrapper(){
            userNameMissing = true;
            newsletterIdMissing = true;
            statusMissing = true;
            extendedStatusMissing = true;
            campaignName = true;
            
        }
    }
}