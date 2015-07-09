<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="t" %>
<%@ taglib tagdir="/WEB-INF/tags/instructor" prefix="ti" %>
<%@ taglib tagdir="/WEB-INF/tags/instructor/results" prefix="r" %>
<%@ page import="teammates.common.util.Const"%>
<%@ page import="teammates.common.util.TimeHelper"%>
<%@ page import="teammates.ui.controller.InstructorFeedbackResultsPageData"%>
<%
    InstructorFeedbackResultsPageData data = (InstructorFeedbackResultsPageData)request.getAttribute("data");
    boolean showAll = data.bundle.isComplete;
    boolean shouldCollapsed = data.bundle.responses.size() > 500;
    boolean noResponses = data.bundle.responses.isEmpty();
%>

<r:sessionPanel sessionPanel="${data.sessionPanel}" />

<%
	if (noResponses == false || !data.selectedSection.equals("All")
			|| !showAll) {
%>

<form class="form-horizontal" role="form" method="post" action="<%=data.getInstructorFeedbackSessionResultsLink(
						data.bundle.feedbackSession.courseId,
						data.bundle.feedbackSession.feedbackSessionName)%>">
    <div class="panel panel-info margin-0">
        <div class="panel-body">
            <div class="row">
                <div class="col-sm-5" data-toggle="tooltip" title="View results in different formats">
                    <div class="form-group">
                        <label for="viewSelect" class="col-sm-2 control-label">
                            View:
                        </label>
                        <div class="col-sm-10">
                            <select id="viewSelect" class="form-control" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_SORTTYPE%>" onchange="this.form.submit()">
                                <option value="question" <%=(data.sortType != null) ? data.sortType
						.equals("question") ? "selected=\"selected\"" : "" : ""%>>
                                    Group by - Question
                                </option>
                                <option value="giver-recipient-question" <%=(data.sortType!=null) ? data.sortType.equals("giver-recipient-question") ? "selected=\"selected\"" : "" : ""%>>
                                    Group by - Giver > Recipient > Question
                                </option>
                                <option value="recipient-giver-question" <%=(data.sortType!=null) ? data.sortType.equals("recipient-giver-question") ? "selected=\"selected\"" : "" : ""%>>
                                    Group by - Recipient > Giver > Question
                                </option>
                                <option value="giver-question-recipient" <%=(data.sortType!=null) ? data.sortType.equals("giver-question-recipient") ? "selected=\"selected\"" : "" : ""%>>
                                    Group by - Giver > Question > Recipient
                                </option>
                                <option value="recipient-question-giver" <%=(data.sortType!=null) ? data.sortType.equals("recipient-question-giver") ? "selected=\"selected\"" : "" : "selected=\"selected\""%>>
                                    Group by - Recipient > Question > Giver
                                </option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="col-sm-5" data-toggle="tooltip" title="Filter the results in the current view">
                    <div class="form-group">
                        <label for="viewSelect" class="col-sm-2 control-label">
                            Filter:
                        </label>
                        <div class="col-sm-10">
                            <div class="input-group">
                                <input type="text" id="results-search-box" class="form-control" placeholder='<%= data.sortType.equals("question") ? "Type keywords from the question to filter" : "Type student/team name/section name to filter"%>' onchange="updateResultsFilter()">
                                <a class="input-group-addon btn btn-default"><span class="glyphicon glyphicon-search"></span></a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-2 pull-right">
                  <div class="col-sm-12" data-toggle="tooltip" title="Group results in the current view by team">
                      <div class="checkbox padding-top-0 min-height-0">
                          <label <%=(data.sortType.equals("question")) ? "class=\"text-strike\"" : ""%>>
                              <input type="checkbox" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYTEAM%>" id="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYTEAM%>" <%=(data.groupByTeam==null) ? "" : "checked=\"checked\""%> <%=(data.sortType.equals("question")) ? "" : "onchange=\"this.form.submit()\""%>> Group by Teams
                          </label>
                      </div>
                  </div>
                  <div class="col-sm-12" data-toggle="tooltip" title="Show statistics">
                      <div class="checkbox padding-top-0 min-height-0">
                          <label <%=(data.sortType.equals("recipient-giver-question") || data.sortType.equals("giver-recipient-question")) ? "class=\"text-strike\"" : ""%>>
                              <input type="checkbox" id="show-stats-checkbox" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_SHOWSTATS%>" <%=(data.showStats==null) ? "" : "checked=\"checked\""%>> Show Statistics
                          </label>
                      </div>
                  </div>
                </div>
            </div>
            <div class="row">
                <% if(data.sections.size() != 0) { %>
                <div class="col-sm-5" data-toggle="tooltip" title="View results by sections">
                    <div class="form-group">
                        <label for="sectionSelect" class="col-sm-2 control-label">
                            Section:
                        </label>
                        <div class="col-sm-10">
                            <select id="sectionSelect" class="form-control" name="<%=Const.ParamsNames.FEEDBACK_RESULTS_GROUPBYSECTION%>" onchange="this.form.submit()">
                                <option value="All" <%=data.selectedSection.equals("All") ? "selected=\"selected\"" : ""%>>
                                    All
                                </option>
                                <% for(String section : data.sections) { %>
                                <option value='<%=section%>' <%=data.selectedSection.equals(section) ? "selected=\"selected\"" : ""%>>
                                    <%=section%>
                                </option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                </div>
                <% } %>
                <div class="col-sm-7 pull-right" style="padding-top:8px;">
                    <% if(!showAll){ %>
                      <div style="display:inline-block;" class="pull-right" data-toggle="tooltip" title="This button is disabled because this session contains more data than we can retrieve at one go. You can still expand one panel at a time by clicking on the panels below.">
                       <a class="btn btn-default btn-xs pull-right" id="collapse-panels-button" onclick="toggleCollapse(this)" <%= showAll ? "" : "disabled='disabled'" %>>
                        Expand <%= data.sortType.equals("question") ? "Questions" : "Sections" %>
                    </a>
                    </div>
                    <% } else { 
                        if(shouldCollapsed){ 
                     %>
                    <a class="btn btn-default btn-xs pull-right" id="collapse-panels-button" onclick="toggleCollapse(this)" data-toggle="tooltip" title="Expand all panels. You can also click on the panel heading to toggle each one individually.">
                        Expand <%= data.sortType.equals("question") ? "Questions" : "Sections" %>
                    </a>
                    <% } else { %>
                    <a class="btn btn-default btn-xs pull-right" id="collapse-panels-button" onclick="toggleCollapse(this)" data-toggle="tooltip" title="Collapse all panels. You can also click on the panel heading to toggle each one individually.">
                        Collapse <%= data.sortType.equals("question") ? "Questions" : "Sections" %>
                    </a>
                    <%    }
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
    <input type="hidden" name="<%=Const.ParamsNames.FEEDBACK_SESSION_NAME%>"
        value="<%=data.bundle.feedbackSession.feedbackSessionName%>">
    <input type="hidden" name="<%=Const.ParamsNames.COURSE_ID%>"
        value="<%=data.bundle.feedbackSession.courseId%>">
    <input type="hidden" name="<%=Const.ParamsNames.USER_ID%>" 
        value="<%=data.account.googleId%>">
</form>
<%
    }
%>
<br>
<t:statusMessage />
<br>
<% if (noResponses && showAll) { %>
    <div class="bold color_red align-center">There are no responses for this feedback session yet or you do not have access to the responses collected so far.</div>
<% } %>
