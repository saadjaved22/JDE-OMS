/**
 * The survey campaign request object send by SurveyCampaignRESTResource
 *
 * @author tim.dirckx@emark.com
 */
public class SurveyCampaignRequest {
  public String campaignProfileId;
  public String accountId;
  public String campaignId;
  public List<SurveyResult> results;
  public List<SurveyQuestion> questions;

  public class SurveyQuestion {
    public String title;
    public String question_id;
    public List<SurveyAnswer> answers;
  }

  public class SurveyAnswer {
    public String title;
    public String answer_id;
    public Boolean selected;
    public String value;
  }

  public class SurveyResult {
    public Integer rank;
    public String name;
    public String value;
    public List<SurveyResultProperty> Properties;
  }

  public class SurveyResultProperty {
    public String name;
    public String value;
  }
}
