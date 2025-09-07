import { LightningElement, wire, track } from 'lwc';
import getCoursesWithModules from '@salesforce/apex/phsCourseController.getCoursesWithModules';
import saveRating from '@salesforce/apex/phsCourseController.saveRating';
import getUserRatings from '@salesforce/apex/phsCourseController.getUserRatings';
import incrementViewCount from '@salesforce/apex/phsCourseController.incrementViewCount';
import getCourseProgress from '@salesforce/apex/phsCourseProgressController.getVideoProgress';
import saveCourseProgress from '@salesforce/apex/phsCourseProgressController.saveVideoProgress';
import My_Resource from '@salesforce/resourceUrl/phsResource';
export default class PhsCourses extends LightningElement {
    searchIcon = My_Resource + '/Icons/search.png';
    courseIcon = My_Resource + '/Icons/coach_120625.png'
    courses = [];
    @track filteredModules = [];
    @track groupedByCourse = [];
    selectedModule = null;
    searchKeyword = '';
    urlSelectedModuleId;
    sortOption = 'recommended';
    userRatings = {};
    userProgress = {};
    lastProgressSaveTime = 0;

    @wire(getCoursesWithModules)
    wiredCourses({ data, error }) {
        if (data) {
            this.courses = data;
            this.fetchProgressAndFilter();
        } else if (error) {
            // console.error('Error fetching courses:', error);
        }
    }

    @wire(getUserRatings)
    wiredUserRatings({ data, error }) {
        if (data) {
            this.userRatings = data;
            this.filterModules();
        } else if (error) {
            // console.error('Error loading user ratings', error);
        }
    }

    fetchProgressAndFilter() {
        getCourseProgress()
            .then(progressList => {
                const progressMap = {};
                (progressList || []).forEach(p => {
                    if (p.moduleId) {
                        progressMap[p.moduleId] = p;
                    } else {
                        // console.warn('ij: Missing moduleId in progress item:', p);
                    }
                });

                this.userProgress = progressMap;
                this.filterModules();
            })
            .catch(error => {
                // console.error('Error fetching progress:', error);
                this.filterModules(); // still filter even if no progress
            });
    }

    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        this.urlSelectedModuleId = urlParams.get('moduleId');

        window.onpopstate = () => {
            const params = new URLSearchParams(window.location.search);
            const moduleId = params.get('moduleId');

            if (moduleId) {
                const mod = this.filteredModules.find(m => m.id === moduleId);
                if (mod) this.selectedModule = mod;
            } else {
                this.selectedModule = null;
            }
        };
        // const courses = [
        //     { courseId: '1', courseName: 'Mathematics' },
        //     { courseId: '2', courseName: 'Physics' },
        //     { courseId: '3', courseName: 'Chemistry' }
        //   ];
        
        //   this.groupedByCourse = courses.map((course, index) => {
        //     return {
        //       ...course,
        //       moduleNumber: `Module ${index + 1}`
        //     };
        //   });
        
        


    }

    handleSearchChange(event) {
        this.searchKeyword = event.target.value.toLowerCase();
        this.filterModules();
    }

    handleSortChange(event) {
        this.sortOption = event.target.value;
        this.filterModules();
    }

    filterModules() {
        let allModules = this.courses.flatMap(course =>
            (course.modules || []).map(mod => {
                const userRating = this.userRatings[mod.id] ?? 0;
                const stars = [1, 2, 3, 4, 5].map(i => ({
                    value: i,
                    className: i <= userRating ? 'star selected' : 'star'
                }));


                const progress = this.userProgress[mod.id];

                let watchedPercentage = 0;
                let resumeTime = 0;
                if (progress) {
                    if (progress.watchPercentage !== undefined) {
                        watchedPercentage = Math.round(parseFloat(progress.watchPercentage));
                    }
                    if (progress.lastWatchedTime !== undefined) {
                        resumeTime = parseFloat(progress.lastWatchedTime);
                    }
                }
                const progressStyle = `width: ${watchedPercentage}%;`;

                return {
                    ...mod,
                    courseName: course.name,
                    courseId: course.id,
                    userRating,
                    hasRated: userRating > 0,
                    stars,
                    watchedPercentage,
                    resumeTime,
                    isWatched: watchedPercentage >= 95,
                    progressStyle
                };
            })
        );

        if (this.searchKeyword) {
            allModules = allModules.filter(mod =>
                mod.name.toLowerCase().includes(this.searchKeyword) || 
                mod.description.toLowerCase().includes(this.searchKeyword) || 
                mod.courseName.toLowerCase().includes(this.searchKeyword)
            );
        }

        switch (this.sortOption) {
            case 'dateNewest':
                allModules.sort((a, b) => new Date(b.createdDate) - new Date(a.createdDate));
                break;
            case 'dateOldest':
                allModules.sort((a, b) => new Date(a.createdDate) - new Date(b.createdDate));
                break;
            case 'popularity':
                allModules.sort((a, b) => (b.views ?? 0) - (a.views ?? 0));
                break;
            case 'alphabetical':
                allModules.sort((a, b) => a.courseName.localeCompare(b.courseName));
                break;
        }

        this.filteredModules = allModules;

        const grouped = {};
        allModules.forEach(mod => {
            if (!grouped[mod.courseId]) {
                grouped[mod.courseId] = {
                    courseId: mod.courseId,
                    courseName: mod.courseName,
                    modules: []
                };
            }
            grouped[mod.courseId].modules.push(mod);
        });

        this.groupedByCourse = Object.values(grouped);

        if (this.urlSelectedModuleId && !this.selectedModule) {
            const mod = this.filteredModules.find(m => m.id === this.urlSelectedModuleId);
            if (mod) {
                this.selectedModule = mod;
                this.urlSelectedModuleId = null;
            }
        }
    }

    handleViewDetails(event) {
        const modId = event.currentTarget.dataset.id;
        const mod = this.filteredModules.find(m => m.id === modId);
        if (mod) {
            this.selectedModule = mod;

            const newUrl = new URL(window.location.href);
            newUrl.searchParams.set('moduleId', mod.id);
            newUrl.searchParams.set('courseId', mod.courseId);
            window.history.pushState({}, '', newUrl);

            incrementViewCount({ moduleId: mod.id })
                // .then(() => 
                // console.log('View count incremented')
                // )
                // .catch(error => 
                //     console.error('Error incrementing view count:', error)
                //     );
        }
    }

    handleMetadataLoaded() {
        const video = this.template.querySelector('video');
        if (video && this.selectedModule?.resumeTime) {
            video.currentTime = this.selectedModule.resumeTime;
        }
    }

    handleVideoProgress(event) {
        const video = event.target;
        const mod = this.selectedModule;
        if (!mod || !video || !video.duration) return;

        const now = Date.now();
        // Only save every 15 seconds or when video ends
        const isEnding = video.duration && video.currentTime >= video.duration - 1;

        if (now - this.lastProgressSaveTime > 15000 || isEnding) {
            this.lastProgressSaveTime = now;
            saveCourseProgress({
                moduleId: mod.id,
                secondsWatched: Math.floor(video.currentTime),
                totalDuration: Math.floor(video.duration)
            }).catch(error => {
                // console.error('Error saving progress:', error);
            });
        }
    }

    handleBack() {
        this.selectedModule = null;
        const newUrl = new URL(window.location.href);
        newUrl.searchParams.delete('moduleId');
        newUrl.searchParams.delete('courseId');
        window.history.pushState({}, '', newUrl);
        this.fetchProgressAndFilter();
    }

    get isExpandedView() {
        return this.selectedModule !== null;
    }

    handleRatingClick(event) {
        const rating = parseInt(event.currentTarget.dataset.value, 10);
        const moduleId = event.currentTarget.dataset.moduleId;

        if (this.userRatings[moduleId]) return;

        saveRating({ moduleId, ratingValue: rating })
            .then(() => {
                const updatedRatings = { ...this.userRatings };
                updatedRatings[moduleId] = rating;
                this.userRatings = updatedRatings;

                if (this.selectedModule?.id === moduleId) {
                    this.selectedModule.userRating = rating;
                    this.selectedModule.hasRated = true;
                    this.selectedModule.stars = [1, 2, 3, 4, 5].map(i => ({
                        value: i,
                        className: i <= rating ? 'star selected' : 'star'
                    }));
                }

                this.filterModules();
            })
            // .catch(error => 
            //     console.error('Error saving rating:', error));
    }

    disableRightClick(event) {
        event.preventDefault();
    }

    getStarClass(star) {
        if (!this.selectedModule || !this.selectedModule.userRating) return 'star';
        return star <= this.selectedModule.userRating ? 'star selected' : 'star';
    }

    get starOptions() {
        return [1, 2, 3, 4, 5];
    }
    // get isComplete() {
    //     return Number(this.mod?.watchedPercentage) === 100;
    //   }
    // getModuleStatus(mod) {
    //     const percent = Number(mod?.watchedPercentage);
    //     if (percent === 100) return 'Completed';
    //     if (percent > 0 && percent < 100) return `Resume - ${percent}% watched`;
    //     return 'Start';
    //   }
      
}