import os
from django.conf import settings
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.exceptions import ValidationError
from apps.common.responses import success

class MediaUploadView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        file_obj = request.FILES.get('file')
        if not file_obj:
            raise ValidationError("No file uploaded")
        
        # Save file to media root
        media_dir = os.path.join(settings.MEDIA_ROOT, 'photos')
        os.makedirs(media_dir, exist_ok=True)
        
        file_path = os.path.join(media_dir, file_obj.name)
        with open(file_path, 'wb+') as destination:
            for chunk in file_obj.chunks():
                destination.write(chunk)
                
        # Build URL
        relative_url = f"{settings.MEDIA_URL}photos/{file_obj.name}"
        url = request.build_absolute_uri(relative_url)
        return success({"url": url}, status=status.HTTP_201_CREATED)
