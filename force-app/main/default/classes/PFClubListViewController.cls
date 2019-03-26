public class PFClubListViewController extends PFBaseController {
    
    public String sortField {get; set;}
    public String currPageNum {get; set;}
    public String pageTitle {get; set;}
    
    private ApexPages.StandardSetController setCntrlr;
    private String prevSortField;
    private String sortDirection;
    private transient static final Integer DEFAULT_NUMBER_OF_RECS_PER_PAGE = 10;
    
    private Set<ID> groupIds;
    
    private String clubStatusStr;
    public Boolean isInListView {get; set;}
    public PFClubListViewController(){
        
        clubStatusStr = ApexPages.currentPage().getParameters().get('status');
        groupIds = new set<ID>();
        ID ownerId;
        if (this.getCurrentUserContact() != null) {
            ownerId = this.getCurrentUserContact().Id;
        }
        
        for( Group_Owner__c go : [SELECT Group_Num__c FROM Group_Owner__c where Owner_Contact__c = :ownerId] ){
            groupIds.add( go.Group_Num__c );
        }
        doQuery();
    }
    
    public void doQuery(){
        this.setCntrlr = null;
        String query = 'SELECT Name, ShippingCity, ShippingState, Status__c FROM Account' +
                        ' where Status__c' + 
            			( clubStatusStr == 'Open' ? ( ' = \'' + clubStatusStr + '\' ' ) : ( ' != \'Open\' and Status__c != \'closed\' ' ) ) + 
            			' and Group_Name__c in :groupIds';
        
        if( sortField != null ) {
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + ' ';
            
            sortDirection = sortField == prevSortField && sortDirection == 'ASC' ? 'DESC' : 'ASC';
            prevSortField = sortField;
            query += sortDirection + ' NULLS LAST ';
        }
        query += ' LIMIT 50000 ';    

        System.debug('query: ' + query);
        this.numberOfPages = null;
        if( this.currPageNum == null )
            this.currPageNum = '1';
        this.setCntrlr = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        this.setCntrlr.setPageSize(Integer.valueOf(numberOfRecsPerPage));
        this.setCntrlr.setPageNumber(getCurrPageNumInt());
        
    }
    
    // *************** Pagination-related function *************** 
    public PageReference jumpToPage() {
            this.setCntrlr.setPageNumber(getCurrPageNumInt());
            return null;
    }

    public Boolean getHasRecords() {
            return this.setCntrlr != null && getRecords().size() > 0;
    }
    
    public Integer numberOfPages {
        get {
            if ( this.numberOfPages == null ) {
                Integer currPageNumber = setCntrlr.getPageNumber();
                setCntrlr.last();
                this.numberOfPages = setCntrlr.getPageNumber();
                setCntrlr.setPageNumber(currPageNumber);
            }
            return this.numberOfPages;
        }
        private set;
    }
    
    public List<SObject> getRecords() {
        return this.setCntrlr != null ? setCntrlr.getRecords() : null;
    }
    
    public Integer getCurrPageNumInt() {
        if ( currPageNum == null || currPageNum == '' || currPageNum == '0' ) {
                currPageNum = '1';
        }
        return Integer.valueOf(currPageNum);
    }
    
    public Boolean getHasPreviousPage() {
        return getCurrPageNumInt() > 1;
    }

    public Boolean getHasNextPage() {
        Integer pageParam = getCurrPageNumInt();
        return getPageNumbers().size() > pageParam;
    }    

    public Integer[] getPageNumbers() {
        Integer[] pageNumbers = new List<Integer>();
        Integer resultSize = setCntrlr.getResultSize();
        if ( setCntrlr.getResultSize() > Integer.valueOf(numberOfRecsPerPage) ) {
            for ( Integer i = 1; i <= this.numberOfPages; i++ ) {
                pageNumbers.add(i);
            }
        }
        return pageNumbers;
    }

    public Boolean getIsAscending() {
            return this.sortDirection == null || this.sortDirection == 'ASC';
    }
    
    public String numberOfRecsPerPage {
        get {
            if ( this.numberOfRecsPerPage == null ) {
                this.numberOfRecsPerPage = String.valueOf(DEFAULT_NUMBER_OF_RECS_PER_PAGE);
            }
            return this.numberOfRecsPerPage;
        }
        set;
    }

}