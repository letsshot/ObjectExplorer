#import <Foundation/Foundation.h>

void listAllClasses()
{
  Class *classes=NULL;
  int total;
  total=objc_getClassList(NULL,0);
  if(total>0){
	classes=malloc(sizeof(Class) *total);
	total=objc_getClassList(classes,total);
	for(int n=0;n<total;n++)
	{
		printf("%s\n",class_getName(classes[n]));
	}
	free(classes);
   }
}
const char *decode_type_char(const char* type)
{
	if(strcmp(type,"c")==0)
	{
        return("char");
	}else if(strcmp(type,"C")==0)
	{
		return("unsigned char");
	}else if(strcmp(type,"i")==0)
	{
		return("int");
	}else if(strcmp(type,"I")==0)
	{
		return("unsigned int");
	}else if(strcmp(type,"l")==0)
	{
		return("long");
	}else if(strcmp(type,"L")==0)
	{
		return("unsigned long");
	}else if(strcmp(type,"f")==0)
	{
		return("float");
	}else if(strcmp(type,"d")==0)
	{
		return("double");
	}else if(strcmp(type,"B")==0)
	{
		return("bool");
	}else if(strcmp(type,"*")==0)
	{
		return("char*");
	}else if(strcmp(type,"@")==0)
	{
		return("Object");
	}else if(strcmp(type,"v")==0)
	{
		return("void");
	}else if(strcmp(type,"#")==0)
	{
		return("Class");
	}else if(strcmp(type,":")==0)
	{
	    return("SEL");
	}else
	{
		return("Complex or unknow");
	}
}

void listAllMethods(const char *clName)
{
  unsigned int nfmethods;
  Method *methods=NULL;
  methods=class_copyMethodList(objc_getClass(clName),&nfmethods);
  for(int n=0;n<nfmethods;n++)
  {
    unsigned int nfArguments = method_getNumberOfArguments(methods[n]);
	printf("%s:",sel_getName(method_getName(methods[n])));
    for(int m=0;m<nfArguments;m++){
        const char* type=method_copyArgumentType(methods[n],m);
			printf("(%s)arg%d",decode_type_char(type),m+1); 
    }
     printf("\n");
    }
  free(methods);
}

void listInstanceVariables(const char* clName)
{
  Ivar* vars=NULL;
  unsigned int total;
  vars=class_copyIvarList(objc_getClass(clName),&total);
  for(int n=0;n<total;n++)
  {
    const char* type=ivar_getTypeEncoding(vars[n]);
	printf("(%s)%s\n",decode_type_char(type),ivar_getName(vars[n]));  						
  }
  free(vars);
 }

 const char *decode_nstype_char(NSString* type)
{
	if([type isEqualToString:@"Tc"])
	{
        	return("char");
	}else if([type isEqualToString:@"TC"])
	{
		return("unsigned char");
	}else if([type isEqualToString:@"Ti"])
	{
		return("int");
	}else if([type isEqualToString:@"TI"])
	{
		return("unsigned int");
	}else if([type isEqualToString:@"Tl"])
	{
		return("long");
	}else if([type isEqualToString:@"TL"])
	{
		return("unsigned long");
	}else if([type isEqualToString:@"Tf"])
	{
		return("float");
	}else if([type isEqualToString:@"Td"])
	{
		return("double");
	}else if([type isEqualToString:@"TB"])
	{
		return("bool");
	}else if([type isEqualToString:@"T*"])
	{
		return("char*");
	}else if([type isEqualToString:@"T@"])
	{
		return("Object");
	}else if([type isEqualToString:@"Tv"])
	{
		return("void");
	}else if([type isEqualToString:@"T#"])
	{
		return("Class");
	}else if([type isEqualToString:@"T:"])
	{
	    return("SEL");
	}else
	{
		return("Complex or unknow");
	}
}
 
void listAllProperties(const char* clName)
{
  unsigned int total;
  objc_property_t *properties=class_copyPropertyList(objc_getClass(clName),&total);
  for(int n=0;n<total;n++)
  {
    const char* level = NULL;
    NSString *attributes=[[NSString alloc] initWithCString:property_getAttributes(properties[n])];
    NSArray *commandOfAttributes=[attributes componentsSeparatedByString:@","];
    if([[commandOfAttributes objectAtIndex:1] isEqualToString:@"R"]){
      level="r/o";
    }else{
      level="r/w";
	}
    printf("(%s)%s,%s\n",decode_nstype_char([commandOfAttributes objectAtIndex:0]),property_getName(properties[n]),level);
  }
  free(properties);
}

void listAllProtocols(const char* clName)
{
  unsigned int total;
  Protocol** protocols=class_copyProtocolList(objc_getClass(clName),&total);
  for(int n=0;n<total;n++)
  {
		printf("ProtocolName:%s\n",protocol_getName(protocols[n]));
		unsigned int numberOfMethods;
		struct objc_method_description* methodsOfProtocols=protocol_copyMethodDescriptionList(objc_getProtocol(protocol_getName(protocols[n])),true,true,&numberOfMethods);
		for(int m=0;m<numberOfMethods;m++){
				Method method;
				method=class_getClassMethod(objc_getClass(clName),methodsOfProtocols[m].name);
				unsigned int numberOfArgs;
				numberOfArgs = method_getNumberOfArguments(method);
				if(numberOfArgs==0)
				{
					printf("Method Name of %s: %s:",protocol_getName(protocols[n]),sel_getName(method_getName(method)));
				}else{
					printf("Method Name of %s: %s:",protocol_getName(protocols[n]),sel_getName(method_getName(method)));
					for(int i=0;i<numberOfArgs;i++){
						printf("(%s)arg%d",decode_type_char(method_copyArgumentType(method,i)),i+1);
					}
					printf("\n");
				}
		}
	}
	free(protocols);
}

int main( int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    char choose[40];
    while(strcmp(choose,"quit")!=0)
    {
      printf("Welcome to Object Explorer!\n");
	  printf("The command you can enter:\n");
      printf("list classes\n");
      printf("list classname methods\n");
      printf("list classname variables\n");
      printf("list classname properties\n");
      printf("list classname protocols\n");
      printf("quit\n");
	  printf("Please enter the command:\n");
      printf("%s",">");
	  
      gets(choose);
      NSArray *command=[[NSString stringWithCString:choose] componentsSeparatedByString:@" "];
      if([command count]==2){
			listAllClasses();
      }else if([command count]==3){
			if([[command objectAtIndex:2] isEqualToString:@"methods"]){
				listAllMethods([[command objectAtIndex:1] UTF8String]);
			}else if([[command objectAtIndex:2] isEqualToString:@"variables"]){
				listInstanceVariables([[command objectAtIndex:1] UTF8String]);
			}else if([[command objectAtIndex:2] isEqualToString:@"properties"]){
				listAllProperties([[command objectAtIndex:1] UTF8String]);
			}else if([[command objectAtIndex:2] isEqualToString:@"protocols"]){
				listAllProtocols([[command objectAtIndex:1] UTF8String]);
			}
		}
	}
	[pool drain];
	return(0);
}

