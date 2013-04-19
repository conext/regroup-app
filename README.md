Since this is HTTP basic auth, try not to test it with your browser. Browsers have a sneaky way of remembering your credentials until you quit (the browser, not your job). Use curl, like so:

curl -u wordpress:letterpull http://localhost:9393/group/1/resources/app1 | jshon    

